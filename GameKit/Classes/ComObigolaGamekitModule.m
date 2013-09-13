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
    NSString *identifier = [[(NSArray *)args objectAtIndex:0] stringValue];
    
    GKLocalPlayer *player;
    player = [GKLocalPlayer localPlayer];
    
    if (player.authenticated == NO) {
        [[GameCenterManager sharedManager] initGameCenter:^(BOOL success) {
            
        }];
    } else {
        GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
        if (leaderboardController != NULL) {
            if (identifier)
                leaderboardController.category = identifier;
            else
                leaderboardController.category = self.currentLeaderBoard;
            
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
    
    NSString* _return = [NSString stringWithFormat:@"{\"id\" : \"%@\", \"alias\" : \"%@\", \"photo\": \"%@\"}", player.playerID, player.alias, imageName];
    
    return _return;
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
