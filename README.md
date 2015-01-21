GameKit Easy Module [![Titanium](http://www-static.appcelerator.com/badges/titanium-git-badge-sq.png)](http://www.appcelerator.com/titanium/)
===
This is a module that integrates Apple's Game Kit API. Currently Leaderboards and Achievements are supported.
You don't need to create a way to save scores locally because this module do it for you, and when a internet connection is available, it sends to Game Center server automagically. ;-)

**Remember:** Logout your regular Game Center account to enable Sandbox mode. 

Getting Started
===
View the [Using Titanium Modules](http://docs.appcelerator.com/titanium/2.0/#!/guide/Using_Titanium_Modules) document for instructions on getting
started with using this module in your application.

Download
===
Download the compiled release [here](https://github.com/bguidolim/TiGameKitEasyModule/tree/master/Dist) or install from gitTio    [![gitTio](http://gitt.io/badge.png)](http://gitt.io/component/com.obigola.gamekit)

Accessing the Ti.GameKit Module
===
To access this module from JavaScript, you would do the following:
```javascript
var GameKit = require('com.obigola.gamekit');
```
Methods
===
### void initGameCenter({ success: &lt;successCallback&gt;, error: &lt;errorCallback&gt; })

Checks if GameKit is available on the current device and connect to Game Center server. Devices must be running iOS 5.0 or later.

Accepts one object with two properties:

*   _callback_ success: Use it if you want to do something after the player was authenticated. This property is **optional**.

*   _callback_ error: Use it if you want to do something after the player cannot be authenticated. This property is **optional**.

### void submitScore(_string_ identifier, _string_ score)

Saves a score for the current user to the specified LeaderBoard

Accepts two arguments:

*   _string_ identifier: The identifier for the LeaderBoard, as set up in your iTunesConnect for this app.
*   _string_ score: The score the user accomplished.

### void showLeaderboard(_string_ identifier)

Shows a particular LeaderBoard to the user.

Accepts a single argument:

*   string identifier: The identifier for the LeaderBoard, as set up in your iTunesConnect for this app. This argument is **optional**, if you not set, the module shows the last LeaderBoard called on submitScore()

### void submitAchievement(_string_ identifier, _string_ percentageEarned)

Saves a score for the current user to the specified LeaderBoard

Accepts two arguments:

*   _string_ identifier: The identifier you set up in your iTunes Connect account for this app.
*   _string_ percentageEarned: A float from 0 to 100 describing how close the user is to completing the achievement. Once reported, achievements cannot be downgraded (so if a user completes 50% of an achievement, you cannot kick them back to only 10% completed).

### void showAchievements()

Shows Game Center Achiviements view.

### void resetAchievements()

Reset all users achievements from Game Center server.

### string getPlayerInfo()

<p>Return a stringfied JSON with:

*   Player ID
*   Alias
*   Photo (Photo is just "Player ID"+".png", you'll need to use Titanium.Filesystem API to access the image. See example file.)
<p>To parse this string, use JSON.parse() function.

### void getLeaderboardScore({ identifier: _string_, topOf: _int_, success: &lt;successCallback&gt;, error: &lt;errorCallback&gt; })

<p>Get scores from a specified Leaderboard.

Accepts one object with four properties:

*   _string_ identifier: Set which Leaderboard you want to get scores.

*   _int_ topOf: Set users limit that you want to get from Leaderboard, like "Top 15". It's limited to 100. Default value is 25. This property is **optional**.

*   _callback_ success(response): Use it to manage scores.

       *   _object_ response: { _object_ localPlayer, _array_ playersInfo, _array_ scores}

*   _callback_ error: Use it if you want to do something after the scores cannot be returned. This property is **optional**.

## Usage

See example.

## Author

[@bguidolim](http://twitter.com/bguidolim)

## Module History

View the [change log](CHANGELOG.md) for this module.
