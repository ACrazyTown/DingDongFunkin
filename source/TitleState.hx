package;

import donut.load.LoadedAssets;
import donut.shader.FisheyeShader;
import donut.shader.FlxShaderToyShader;
import openfl.filters.ShaderFilter;
import donut.GameData;
import flixel.FlxSubState;
import lime.app.Application;

import openfl.Assets;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import donut.achievement.AchievementData;

#if desktop
import Discord.DiscordClient;
#end

using StringTools;

class TitleState extends MusicBeatState
{
	//static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var textGroup:FlxGroup;
	var ding:FlxSprite;

	var curWacky:Array<String> = [];

	override public function create():Void
	{
		super.create();

		if (!GlobalTracker.titleInit)
		{
			#if (desktop && !hl)
			DiscordClient.initialize();
			#end

			PlayerSettings.init();
			//KeyBinds.load();
			KadeEngineData.initSave();
			GameData.init();
			Highscore.load();
			AchievementData.init();

			Application.current.onExit.add(function(exitCode) 
			{
				AchievementData.save();
				#if (desktop && !hl)
				DiscordClient.shutdown();
				#end
			});

			curWacky = FlxG.random.getObject(getIntroTextShit());

			if (FlxG.save.data.firstBoot == true)
			{
				// we do this because globaltracker is gonna save it for 1 session regardless, so... :P
				GlobalTracker.isFirstTime = true;
				MusicBeatState.switchState(new WarningState());
			}

			FlxG.game.focusLostFramerate = FlxG.save.data.fpsCap;
			FlxG.sound.muteKeys = [ZERO];
		}

		//CoolUtil.pushGameFilters([new ShaderFilter(new FisheyeShader())]);

		Conductor.bpm = 172;

		LoadedAssets.add(Paths.assetPath("freakyMenu", null, MUSIC), null, MUSIC);
		LoadedAssets.add(Paths.assetPath("alphabet", null, IMAGE), null, IMAGE);

		//if (!AssetCache.exists(Paths.image("alphabet")))
		//	AssetCache.add(Paths.image("alphabet")); // ok, I know we said no preloading but like... its UI...

		#if NEWMENU
		MusicBeatState.switchState(new MainMenuState());
		#elseif NEWSTORY
		MusicBeatState.switchState(new StoryMenuState());
		#elseif FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#elseif ACHIEVEMENT
		MusicBeatState.switchState(new AchievementState());
		#elseif TESTING
		MusicBeatState.switchState(new TestingState());
		#elseif PLAYSTATETEST
		PlayState.SONG = Song.loadFromJson(Highscore.formatSong("allergy", 1), "allergy");
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = 1;
		PlayState.storyWeek = 1;
		donut.load.LoadState.loadAndSwitchState(new PlayState());
		//FlxG.switchState(new PlayState());
		#else
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#end
	}

	var logoBl:FlxSprite;
	var titleDing:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var titleLads:FlxSprite;
	var bg:FlxSprite;

	function startIntro():Void
	{
		persistentUpdate = true;

		bg = new FlxSprite(-7, -38).loadGraphic(Paths.image("title/dingTitleBG"));
		add(bg);

		gfDance = new FlxSprite(171.85, 78.65);
		gfDance.frames = Paths.getSparrowAtlas("title/budSpeaker");
		gfDance.animation.addByIndices('danceLeft', 'laploink', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'laploink', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.setGraphicSize(Std.int(571.8));
		gfDance.updateHitbox();
		add(gfDance);

		titleDing = new FlxSprite(15.9, 185.5);
		titleDing.frames = Paths.getSparrowAtlas('title/dingTitle');
		titleDing.animation.addByPrefix('bop', 'dingd Idle', 24, false);
		titleDing.animation.addByPrefix("swag", "dingd Taunt", 24, false);
		add(titleDing);

		logoBl = new FlxSprite(480, -85);
		logoBl.frames = Paths.getSparrowAtlas('title/dingLogoBumpin');
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		add(logoBl);

		var titleTextBG = new FlxSprite(0, FlxG.height * 0.8).makeGraphic(FlxG.width, 90, FlxColor.BLACK);
		titleTextBG.alpha = 0.85;
		add(titleTextBG);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('title/dingTitleText');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);

		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		ding = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('dingdongdirt'));
		ding.frames = Paths.getSparrowAtlas("title/dingTitleWave");
		ding.animation.addByPrefix("wave", "sussy", 24);
		ding.visible = false;
		ding.setGraphicSize(Std.int(350));
		ding.y += 20;
		ding.updateHitbox();
		ding.screenCenter(X);
		add(ding);

		titleLads = new FlxSprite(49, 330).loadGraphic(Paths.image('helperLads'));
		titleLads.visible = false;
		add(titleLads);

		//trace(CoolUtil.getUsername());

		if (!GlobalTracker.titleInit)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		if (GlobalTracker.titleInit)
			skipIntro();
		else
			GlobalTracker.titleInit = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	var dingSwag:Bool = false;

	override function update(elapsed:Float):Void
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.keys.justPressed.F)
			FlxG.fullscreen = !FlxG.fullscreen;

		if (Main.debugMode)
		{
			if (FlxG.keys.justPressed.FIVE)
				Main.achv.trigger("week1");
			if (FlxG.keys.justPressed.ONE)
				titleDing.animation.play("bop");
			if (FlxG.keys.justPressed.TWO)
				titleDing.animation.play("swag");
			if (FlxG.keys.justPressed.THREE)
				titleDing.offset.set(0, 0);
			if (FlxG.keys.justPressed.SIX)
				FlxG.switchState(new OffsetTool());
			if (FlxG.keys.justPressed.SEVEN)
				FlxG.switchState(new AlphabetTest());
		}

		if (controls.ACCEPT && !transitioning && skippedIntro)
		{
			if (ding != null && titleLads != null && credGroup != null)
			{
				ding.destroy();
				titleLads.destroy();
				credGroup.destroy();
			}
				
			titleDing.animation.play("swag");
			titleDing.offset.x = 39;
			titleDing.offset.y = 2;
			dingSwag = true;

			if (FlxG.save.data.flashing)
			{
				titleText.animation.play('press');
				titleText.offset.set(-6, -6);
			}

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			new FlxTimer().start(0.75, function(tmr:FlxTimer)
			{
				MusicBeatState.switchState(new MainMenuState());
				closedState = true;

				//if (DLCManager.isAvailable() && FlxG.save.data.showOfflineWarning)
					//super.openSubState(new OfflinePopup());

				// FUCK TRANSITIONS, HIS ANIMATION GONNA SWITCH AND THATS IT
			});
		}

		if (controls.ACCEPT && !skippedIntro && GlobalTracker.titleInit)
			skipIntro();

		super.update(elapsed);
	}

	function openSubstate(SubState:FlxSubState):Void
	{
		super.openSubState(SubState);
	}

	function createCoolText(textArray:Array<String>, ?offsetX:Float, ?offsetY:Float)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
			money.screenCenter(X);
			money.y += (i * 60) + 200;

			if (offsetX != null)
				money.offset.x = offsetX;
			if (offsetY != null)
				money.offset.y = offsetY;

			if (credGroup != null && textGroup != null) 
			{
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String):Void
	{
		if (textGroup != null && credGroup != null) 
		{
			var coolText:Alphabet = new Alphabet(0, 0, text);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText():Void
	{
		if (textGroup != null)
		{
			while (textGroup.members.length > 0)
			{
				if (credGroup.members[0] != null)
					credGroup.remove(textGroup.members[0], true);
				if (credGroup.members[0] != null)
					textGroup.remove(textGroup.members[0], true);
			}
		}
	}

	var sickBeats:Int = 0;
	var closedState:Bool = false;
	override function beatHit():Void
	{
		super.beatHit();

		if (gfDance != null) 
		{
			danceLeft = !danceLeft;
			gfDance.animation.play(danceLeft ? 'danceRight' : 'danceLeft');
		}

		if (titleDing != null && logoBl != null)
		{
			if (curBeat % 2 == 0)
			{
				if (!dingSwag)
					titleDing.animation.play('bop', true);
				logoBl.animation.play('bump', true);
			}
			
		}
	
		if (!closedState && !skippedIntro)
		{
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					createCoolText(['a crazy town']);
				case 12:
					addMoreText('presents');
				//case 15:
				//	deleteCoolText();
				case 18:
					deleteCoolText();
				case 20:
					createCoolText(['with help from', 'anttv', 'dorbellprod', 'despawnedd'], 300, 140);
				case 28:
					//addMoreText('mod');
					createCoolText(['and', 'maryshmary', 'dakota'], -340, 140);
					if (titleLads != null) titleLads.visible = true;
				//case 31:
				case 34:
					if (titleLads != null)
						titleLads.visible = false;
					deleteCoolText();
				case 36:
					createCoolText(['a mod based on']);
				case 40:
					addMoreText('dingdongdirt');
					if (ding != null)
					{
						ding.visible = true;
						ding.animation.play("wave");
					}
				case 46:
					deleteCoolText();
					if (ding != null)
					{
						ding.visible = false;
						ding.animation.stop();
					}

				case 48:
					createCoolText([curWacky[0]]);			
				case 56:
					addMoreText(curWacky[1]);			
				case 64:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			FlxG.camera.flash(FlxColor.WHITE, 4);

			if (ding != null)
				remove(ding, true);
			if (titleLads != null)
				remove(titleLads, true);
			if (credGroup != null)
				remove(credGroup, true);

			skippedIntro = true;
		}
	}
}
