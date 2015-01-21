var gamekit = require('com.obigola.gamekit');

var win = Ti.UI.createWindow({
	backgroundColor:'white'
});

var btn = Ti.UI.createButton({
	title: 'Submit Score',
	top: 22,
	left: 50,
	width: 200
});

var btn2 = Ti.UI.createButton({
	title: 'Show Leaderboard',
	top: 62,
	left: 50,
	width: 200
});

var btn3 = Ti.UI.createButton({
	title: 'Submit Achievement',
	top: 102,
	left: 50,
	width: 200
});

var btn4 = Ti.UI.createButton({
	title: 'Show Achievements',
	top: 142,
	left: 50,
	width: 200
});

var btn5 = Ti.UI.createButton({
	title: 'Reset Achievements',
	top: 182,
	left: 50,
	width: 200
});

var btn6 = Ti.UI.createButton({
	title: 'Get Scores',
	top: 222,
	left: 50,
	width: 200
});

win.add(btn);
win.add(btn2);
win.add(btn3);
win.add(btn4);
win.add(btn5);
win.add(btn6);
win.open();

btn.addEventListener('click', function(e){
	gamekit.submitScore('grp.com.obigola.lightsout.maxpoints','30000');	
});

btn2.addEventListener('click', function(e){
	gamekit.showLeaderboard('com.obigola.lightsout.maxpointsmix');	
});

btn3.addEventListener('click', function(e){
	gamekit.submitAchievement('com.obigola.lightsout.module1','100.0');
});

btn4.addEventListener('click', function(e){
	gamekit.showAchievements();
});

btn5.addEventListener('click', function(e){
	gamekit.resetAchievements('');
});

btn6.addEventListener('click', function(e){
	gamekit.getLeaderboardScore({
		identifier: 'grp.com.obigola.lightsout.totalpoints',
		success: function(response) {
			Titanium.API.info(response);
		},
		error: function() {
			Titanium.API.info('Error callback');	
		}
	});
});


gamekit.initGameCenter({
	success: function() {
		var player = gamekit.getPlayerInfo();
		player = JSON.parse(player);
	
		var playerName = Ti.UI.createLabel({
			text: 'Player ID: '+player.id,
			top: 260
		});
	
		var playerAlias = Ti.UI.createLabel({
			text: 'Player Alias: '+player.alias,
			top: 285
		});
		
		var playerPhoto = Ti.UI.createImageView({
			image: Ti.Filesystem.getFile(Ti.Filesystem.getApplicationDataDirectory()+player.photo),
			top: 310
		});
		
		win.add(playerName);
		win.add(playerAlias);
		win.add(playerPhoto);
	},
	error: function() {
		Titanium.API.info('Error callback');
	}
});
