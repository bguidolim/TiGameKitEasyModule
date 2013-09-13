/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "ComObigolaGamekitModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"

@implementation ComObigolaGamekitModule

@synthesize gameCenterManager;
@synthesize currentScore;
@synthesize currentLeaderBoard;

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#pragma Public APIs

-(void)initGameCenter:(id)args {
    if([GameCenterManager isGameCenterAvailable])   {
        id success = [[args objectAtIndex:0] objectForKey:@"success"];
        
		self.gameCenterManager= [[[GameCenterManager alloc] init] autorelease];
		[self.gameCenterManager setDelegate: self];
        
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        
        if(localPlayer.isAuthenticated == NO){
            if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
                [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error){
                    if (success && [GKLocalPlayer localPlayer].authenticated == YES) {
                        [self _fireEventToListener:@"success" withObject:nil listener:success thisObject:nil];
                    }
                }];
            } else {
                [localPlayer setAuthenticateHandler:^(UIViewController* viewcontroller, NSError *error) {
                    if (!error && viewcontroller) {
                        [[TiApp app] showModalController:viewcontroller animated:YES];
                    } else {
                        if (success && [GKLocalPlayer localPlayer].authenticated == YES) {
                            [self _fireEventToListener:@"success" withObject:nil listener:success thisObject:nil];
                        }
                    }
                }];
            }
        }
	} else {
		[self showAlertWithTitle: @"Game Center Support Required!"
						 message: @"The current device does not support Game Center, which this sample requires."];
	}
}

-(id)getPlayerInfo:(id)args {
    GKLocalPlayer *player = [self.gameCenterManager getPlayer];
    NSString *imageName = [NSString stringWithFormat:@"%@.png",player.playerID];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];

    NSString* _return = [NSString stringWithFormat:@"{\"id\" : \"%@\", \"alias\" : \"%@\", \"photo\": \"%@\"}", player.playerID, player.alias, imageName];
    
    return _return;
}

-(id)submitScore:(id)args {
    self.currentLeaderBoard = (NSString *)[(NSArray *)args objectAtIndex:0];
    self.currentScore = [(NSString *)[(NSArray *)args objectAtIndex:1] longLongValue];
    
    [self.gameCenterManager reportScore:self.currentScore forCategory: self.currentLeaderBoard];
    
    return @"";
}

-(id)submitAchievement:(id)args{
    NSString *identifier = (NSString *)[(NSArray *)args objectAtIndex:0];
    float percentComplete = [(NSString *)[(NSArray *)args objectAtIndex:1] floatValue];
    
    [self.gameCenterManager submitAchievement: identifier percentComplete: percentComplete];

    return @"";
}

-(id)showLeaderboard:(id)args {
    NSString *identifier = (NSString *)[(NSArray *)args objectAtIndex:0];
    
    GKLocalPlayer *player;
    player = [GKLocalPlayer localPlayer];
    
    if (player.authenticated == NO) {
        [self.gameCenterManager authenticateLocalUser];
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
    
    return @"";
}

-(id)resetAchievements:(id)args{
    [self.gameCenterManager resetAchievements];
}

/*
-(id)showAchievements:(id)args {
	GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];
	if (achievements != NULL)
	{
		achievements.achievementDelegate = self;
        [[TiApp app] showModalController:achievements animated:YES];
	}
}
*/ 
 
-(void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController;
{
    [[TiApp app] hideModalController:viewController animated:YES];
    [viewController release];
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	[[TiApp app] hideModalController:viewController animated:YES];
    [viewController release];
}

-(void)showAlertWithTitle:(NSString*)title message:(NSString*)message {
	UIAlertView* alert= [[[UIAlertView alloc] initWithTitle: title
                                                    message: message
                                                    delegate: NULL
                                                    cancelButtonTitle: @"OK"
                                                    otherButtonTitles: NULL] autorelease];
	[alert show];
	
}

- (void) scoreReported: (NSError*) error;
{
	if(error == NULL)
	{
		[self.gameCenterManager reloadHighScoresForCategory: self.currentLeaderBoard];
		/*
        [self showAlertWithTitle: @"High Score Reported!"
						 message: [NSString stringWithFormat: @"", [error localizedDescription]]];
        */
	} else {
		[self showAlertWithTitle: @"Score Report Failed!"
						 message: [NSString stringWithFormat: @"Reason: %@", [error localizedDescription]]];
	}
}


#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"b353ccbe-c942-46f7-b11e-9295a28c6271";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"com.obigola.gamekit";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
	
	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added 
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}

@end
