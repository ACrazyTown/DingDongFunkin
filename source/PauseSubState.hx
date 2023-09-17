package;

import openfl.events.KeyboardEvent;
import flixel.FlxCamera;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

using StringTools;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	var grpOptionShit:FlxTypedGroup<FlxText>;

	var menuItems:Array<String> = [];

	var prevOptions:Array<String> = [];
	var difficultyChoices:Array<String> = ["EASY", "NORMAL", "NUTS", "BACK"];
	var pauseOptions:Array<String> = ['Resume', 'Restart Song', 'Quick Options', 'Exit to menu'];
	var quickOptions:Array<String> = ["Change Controls", "Change Difficulty", "Options Menu", "Back"];

	var prevSelected:Int = 0;
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	//var perSongOffset:FlxText;
	
	var offsetChanged:Bool = false;

	public function new():Void
	{
		super();

		//_cam = new FlxCamera();
		//_cam.bgColor.alpha = 0;
		//FlxG.cameras.add(_cam, false);
		
		menuItems = pauseOptions;

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		bg.active = false;
		add(bg);

		grpOptionShit = new FlxTypedGroup<FlxText>();
		add(grpOptionShit);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		grpOptionShit.add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyFromInt(PlayState.storyDifficulty, true).toUpperCase();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		grpOptionShit.add(levelDifficulty);

		var blueBalled:FlxText = new FlxText(20, 32 + 48, 0, "Blue-balled: 0", 32);
		blueBalled.text = "Blue-balled: " + PlayState.deaths;
		blueBalled.scrollFactor.set();
		blueBalled.setFormat(Paths.font('vcr.ttf'), 32);
		blueBalled.updateHitbox();
		grpOptionShit.add(blueBalled);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;
		blueBalled.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		blueBalled.x = FlxG.width - (blueBalled.width + 20);

		FlxTween.tween(bg, {alpha: 0.7}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(blueBalled, {alpha: 1, y: blueBalled.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		regenMenu();
		changeSelection();

		if (PlayState.instance != null)
		{
			PlayState.instance.camGame.canScroll = false;
			cameras = [PlayState.instance.camOther];
		}
		else
			cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	var antiSpam:Bool = false;

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		if (!antiSpam)
		{
			if (controls.UI_UP_P)
				changeSelection(-1);
			if (controls.UI_DOWN_P)
				changeSelection(1);
			
			if (controls.BACK && menuItems != pauseOptions)
			{
				menuItems = pauseOptions;
				regenMenu();
			}

			if (controls.ACCEPT)
			{
				var daSelected:String = menuItems[curSelected];
				switch (daSelected.toLowerCase())
				{
					case "resume":
						antiSpam = true;
						
						if (FlxG.save.data.pauseCountdown)
						{
							remove(grpMenuShit);

							var swagCounter:Int = 0;
							new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
							{
								var introAlts:Array<String> = ["ready", "set", "go"];
					
								switch (swagCounter)
					
								{
									case 0:
										FlxG.sound.play(Paths.sound('intro3'), 0.6);
									case 1:
										var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
										ready.screenCenter();
										add(ready);

										FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
											ease: FlxEase.cubeInOut,
											onComplete: function(twn:FlxTween)
											{
												ready.destroy();
											}
										});
										FlxG.sound.play(Paths.sound('intro2'), 0.6);
									case 2:
										var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
										//set.setGraphicSize(Std.int(set.width / 2), Std.int(set.height / 2));
										//set.scrollFactor.set();
										set.screenCenter();
										add(set);
										FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
											ease: FlxEase.cubeInOut,
											onComplete: function(twn:FlxTween)
											{
												set.destroy();
											}
										});
										FlxG.sound.play(Paths.sound('intro1'), 0.6);
									case 3:
										var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
										//go.scrollFactor.set();
										//go.setGraphicSize(Std.int(go.width / 2), Std.int(go.height / 2));
										//go.updateHitbox();
										go.screenCenter();
										add(go);
										FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
											ease: FlxEase.cubeInOut,
											onComplete: function(twn:FlxTween)
											{
												go.destroy();
											}
										});
										FlxG.sound.play(Paths.sound('introGo'), 0.6);
									case 4:
										exit();
								}
						
								swagCounter += 1;
							}, 5);
						}
						else
						{
							exit();
						}

						//close();
					case 'easy', 'normal', 'nuts':
						var poop:String = Highscore.formatSong(StringTools.replace(PlayState.SONG.song, " ", "-"), curSelected);
						PlayState.SONG = Song.loadFromJson(poop, PlayState.SONG.song);
						PlayState.storyDifficulty = curSelected;
						MusicBeatState.switchState(new PlayState());
					case "back":
						menuItems = prevOptions;
						regenMenu();
						curSelected = prevSelected;
						changeSelection();
					case "change difficulty":
						prevSelected = curSelected;
						prevOptions = menuItems;
						menuItems = difficultyChoices;
						regenMenu();
					case "restart song":
						MusicBeatState.resetState();
					case 'quick options':
						prevSelected = curSelected;
						prevOptions = menuItems;
						menuItems = quickOptions;
						regenMenu();
					case 'change controls':
						var kbMenu:KeyBindMenu = new KeyBindMenu();
						kbMenu.cameras = (PlayState.instance == null) ? [FlxG.cameras.list[FlxG.cameras.list.length - 1]] : [PlayState.instance.camOther];
						super.openSubState(kbMenu);
					case 'options menu':				
						OptionsMenu.fromPause = true;
						MusicBeatState.switchState(new OptionsMenu());
					case "exit to menu":
						PlayState.deaths = 0;
						PlayState.seenCutscene = false;		

						if (PlayState.isStoryMode)
						{
							MusicBeatState.switchState(new MainMenuState());
						}
						else
						{
							trace("returnin to freeplay i think");
							MusicBeatState.switchState(new FreeplayState());
						}

						pauseMusic.stop();

						if (FlxG.sound.music != null && FlxG.sound.music.playing)
							FlxG.sound.music.stop();
						FlxG.sound.playMusic(Paths.music("freakyMenu"));
				}
			}
		}
	}


	function exit():Void
	{
		pauseMusic.stop();

		if (PlayState.instance != null)
			PlayState.instance.camGame.canScroll = true;

		close();
	}

	function regenMenu():Void
	{
		grpMenuShit.clear();

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		curSelected = 0;
		changeSelection();

		//cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	function changeSelection(change:Int = 0):Void
	{
		if (change != 0)
			FlxG.sound.play(Paths.sound("scrollMenu"));

		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
