/**
 * Bruno Guidolim
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "ComObigolaGamekitModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"
#import "GameCenterManager.h"

@implementation ComObigolaGamekitModule

#pragma mark - Public Methods
-(void)initGameCenter:(id)args {
    
    id successEvent = [[args objectAtIndex:0] objectForKey:@"success"];
    id errorEvent   = [[args objectAtIndex:0] objectForKey:@"error"];
    
    [[GameCenterManager sharedManager] initGameCenter:^(BOOL success) {
        if (success && successEvent) {
            [self _fireEventToListener:@"success" withObject:nil listener:successEvent thisObject:nil];
        } else if (!success && errorEvent) {
            [self _fireEventToListener:@"error" withObject:nil listener:errorEvent thisObject:nil];
        }
    }];
}

-(void)submitScore:(id)args {
    self.currentLeaderBoard = (NSString *)[(NSArray *)args objectAtIndex:0];
    self.currentScore = [(NSString *)[(NSArray *)args objectAtIndex:1] longLongValue];
    
    [[GameCenterManager sharedManager] saveAndReportScore:self.currentScore leaderboard:self.currentLeaderBoard];
}

-(void)showLeaderboard:(id)args {
    NSString *identifier = (NSString *)[(NSArray *)args objectAtIndex:0];
    
    GKLocalPlayer *player;
    player = [GKLocalPlayer localPlayer];
    
    if (player.authenticated == NO) {
        [[GameCenterManager sharedManager] initGameCenter:^(BOOL success) {
            
        }];
    } else {
        GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
        if (leaderboardController != NULL) {
            if ([identifier length] > 0) {
                leaderboardController.category = identifier;
            } else {
                leaderboardController.category = self.currentLeaderBoard;
            }
            
            leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
            leaderboardController.leaderboardDelegate = self;
    
            [[TiApp app] showModalController:leaderboardController animated:YES];
        }
    }
}

-(void)showAchievements:(id)args {
	GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];
	if (achievements != NULL)
	{
		achievements.achievementDelegate = self;
        [[TiApp app] showModalController:achievements animated:YES];
	}
}

-(void)submitAchievement:(id)args{
    NSString *identifier = (NSString *)[(NSArray *)args objectAtIndex:0];
    double percentComplete = [(NSString *)[(NSArray *)args objectAtIndex:1] doubleValue];
    
    [[GameCenterManager sharedManager] saveAndReportAchievement:identifier percentComplete:percentComplete];
}

-(void)resetAchievements:(id)args{
    [[GameCenterManager sharedManager] resetAchievements];
}

-(id)getPlayerInfo:(id)args {
    GKLocalPlayer *player = [[GameCenterManager sharedManager] getPlayer];
    NSString *imageName = [NSString stringWithFormat:@"%@.png",player.playerID];
    
    NSString *_return = [NSString stringWithFormat:@"{\"id\" : \"%@\", \"alias\" : \"%@\", \"photo\": \"%@\"}", player.playerID, player.alias, imageName];
    
    return _return;
}

-(void)getLeaderboardScore:(id)args {
    id successEvent         = [[args objectAtIndex:0] objectForKey:@"success"];
    id errorEvent           = [[args objectAtIndex:0] objectForKey:@"error"];
    id identifier           = [[args objectAtIndex:0] objectForKey:@"identifier"];
    NSUInteger top           = (NSUInteger)[[[args objectAtIndex:0] objectForKey:@"topOf"] integerValue];
    
    if (top <= 0) {
        top = 25;
    } if (top > 100) {
        top = 100;
    }

//    GKLocalPlayer *player;
//    player = [GKLocalPlayer localPlayer];
    
    GKLeaderboard *leaderboard = [[GKLeaderboard alloc] init];
    leaderboard.playerScope = GKLeaderboardPlayerScopeFriendsOnly;
    leaderboard.timeScope = GKLeaderboardTimeScopeAllTime;
    leaderboard.identifier = (NSString *)identifier;
    leaderboard.category = (NSString *)identifier;
    leaderboard.range = NSMakeRange(1, top);
    
    [leaderboard loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
        if (error != nil) {
            NSLog(@"[ERROR] %@", error.localizedDescription);
            [self _fireEventToListener:@"error" withObject:nil listener:errorEvent thisObject:nil];
        }
        
        NSMutableDictionary *returnDict = [[NSMutableDictionary alloc] init];
        NSMutableArray *retrievePlayerIDs = [[NSMutableArray alloc] init];
        
        if (scores != nil) {
            NSMutableArray *scoresArray = [[NSMutableArray alloc] init];
        
            for (GKScore *s in scores) {
                [retrievePlayerIDs addObject:s.playerID];
                
                NSDictionary *dictScore =[NSDictionary dictionaryWithObjectsAndKeys:
                                          s.playerID, @"playerID",
                                          [NSNumber numberWithInteger:s.value], @"scoreValue",
                                          s.formattedValue, @"formattedValue",
                                          [NSNumber numberWithInteger:s.rank], @"rankPosition", nil];
                
                [scoresArray addObject:dictScore];
            }
            
            [returnDict setObject:scoresArray forKey:@"scores"];
            
            NSDictionary *meDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInteger:leaderboard.localPlayerScore.value], @"value",
                                    leaderboard.localPlayerScore.formattedValue, @"formattedValue",
                                    [NSNumber numberWithInteger:leaderboard.localPlayerScore.rank], @"rankPosition", nil];
            [returnDict setObject:meDict forKey:@"localPlayer"];
            
            NSMutableArray *playersInfo = [[NSMutableArray alloc] init];
            [GKPlayer loadPlayersForIdentifiers:retrievePlayerIDs withCompletionHandler:^(NSArray *players, NSError *error) {
                for (GKPlayer *p in players) {
                    NSDictionary *playerDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                p.playerID, @"playerID",
                                                p.alias, @"alias",
                                                p.displayName, @"displayName", nil];
                    [playersInfo addObject:playerDict];
                }
                
                [returnDict setObject:playersInfo forKey:@"playersInfo"];
                
                [self _fireEventToListener:@"success" withObject:returnDict listener:successEvent thisObject:nil];
            }];
        }
    }];
}

#pragma GameKit Delegate
-(void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
    [[TiApp app] hideModalController:viewController animated:YES];
    [viewController release];
}

-(void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController {
    [[TiApp app] hideModalController:viewController animated:YES];
    [viewController release];
}

#pragma mark Internal - Appcelerator
-(id)moduleGUID
{
	return @"b353ccbe-c942-46f7-b11e-9295a28c6271";
}

-(NSString*)moduleId
{
	return @"com.obigola.gamekit";
}


-(void)startup
{
	[super startup];
	
	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	[super shutdown:sender];
}

-(void)dealloc
{
	[super dealloc];
}

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	[super didReceiveMemoryWarning:notification];
}
@end
