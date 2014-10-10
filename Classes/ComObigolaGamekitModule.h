/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "TiModule.h"
#import <GameKit/GameKit.h>

@interface ComObigolaGamekitModule : TiModule <GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate>
{
}

@property (nonatomic, assign) int64_t currentScore;
@property (nonatomic, retain) NSString *currentLeaderBoard;

@end
