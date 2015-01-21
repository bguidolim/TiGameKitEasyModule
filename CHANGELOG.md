# Change Log

##0.7	
64-bit Support
##0.6
* Added method getLeaderboardScore() to get scores directly from Game Center server;
##0.5
* Fixed crash when showLeaderboard was called with an argument;
* Maybe this bug will occurs on iOS 5 and 6: https://devforums.apple.com/message/847879

##0.4	
 * iOS 7 support;
 * Now initGameCenter has error callback;
 * Method ShowAchievements added;

***NEW FEATURE:*** Now the GameKit Easy Module turn more easier for developers saving score and achievements when are submitted but not synchronized with server and will test if device have internet connection and will try to send automatically.

##0.3
* Added a success callback argument into method initGameCenter();
* The login screen will open if the player is not authenticated and the method showLeaderboard() was called;

##0.2
* Added method resetAchievements();
* Added function getPlayerInfo():
    * This function returns a stringfied JSON with:
	  - Player ID;
	  - Alias;
	  - Photo (Photo = Player ID + ".png", you'll need to use Titanium.Filesystem API);

##0.1
* Initial Release;
