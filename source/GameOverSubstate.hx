package;

import flixel.math.FlxMath;
import openfl.Assets;
import Character.CharacterFile;
import haxe.Json;
import donut.GameData;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;

	var camFollowPos:FlxObject;
	var camFollow:FlxPoint;

	var gameOverSound:FlxSound;
	var center:FlxPoint;

	var randNumber:Int;
	
	public function new(x:Float = 0, y:Float = 0)
	{
		var player:String = PlayState.SONG.player1;
		var charData:CharacterFile = Json.parse(Assets.getText(Paths.char(player)));
		var daBf:String = "";
		
		if (charData.deathChar != null && charData.deathChar != "" 
			&& GameData.characters.contains(charData.deathChar))
			daBf = charData.deathChar;
		else
			daBf = GameData.characters.contains('$player-dead') ? '$player-dead' : player;

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(FlxG.camera.scroll.x + x, FlxG.camera.scroll.y + y, daBf);
		add(bf);

		camFollow = bf.getGraphicMidpoint();

		camFollowPos = new FlxObject(FlxG.camera.scroll.x, FlxG.camera.scroll.y, 1, 1);
		add(camFollowPos);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx'));
		Conductor.bpm = 80;

		bf.playAnim('firstDeath');
		bf.updateHitbox();

		gameOverSound = new FlxSound();
		gameOverSound.loadEmbedded(Paths.music("gameOverEnd"));
		gameOverSound.persist = true;
		FlxG.sound.list.add(gameOverSound);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);

		var ins:PlayState = PlayState.instance;
		if (ins != null)
		{
			camFollowPos.x = ins.camFollowPos.x;
			camFollowPos.y = ins.camFollowPos.y;

			if (PlayState.gf != null)
				PlayState.gf.playAnim("sad", true);

			if (PlayState.boyfriend != null)
				PlayState.boyfriend.visible = false;

			if (ins.camHUD != null)
				FlxTween.tween(ins.camHUD, {alpha: 0}, 0.95);

			var backg:FlxSprite = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
			backg.screenCenter();
			backg.alpha = 0;
			insert(0, backg);

			FlxTween.tween(backg, {alpha: 1}, 1.5, {onComplete: function(t:FlxTween)
			{
				FlxG.camera.bgColor = 0;
				backg.kill();
				remove(backg);
				PlayState.instance.persistentDraw = false;
				backg.destroy();
			}});
		}

		FlxTween.tween(FlxG.camera, {zoom: 0.9}, 1.5);
		randNumber = FlxG.random.int(1, 6);
	}

	var playedSound:Bool = false;
	var canBoogie:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (camFollowPos.x != camFollow.x && camFollowPos.y != camFollow.y)
		{
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2, 0, 1);
			camFollowPos.x = FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal);
			camFollowPos.y = FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal);
		}

		if (controls.ACCEPT)
			endBullshit();

		if (controls.BACK)
		{
			PlayState.deaths = 0;
			PlayState.seenCutscene = false;
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				MusicBeatState.switchState(new StoryMenuState());
			else
				MusicBeatState.switchState(new FreeplayState());
		}

		if (bf.animation.curAnim.name == 'firstDeath')
		{	
			if (bf.animation.curAnim.finished)
			{
				if (!playedSound)
				{
					var isDing:Bool = StringTools.startsWith(PlayState.SONG.player2, "ding");

					playedSound = true;
					FlxG.sound.playMusic(Paths.music('gameOver'), isDing ? 0.2 : 1);
					
					if (isDing)
					{
						FlxG.sound.play(Paths.sound('gameover/ding_gameover_$randNumber'), 1, false, null, true, function()
						{
							FlxG.sound.music.fadeIn(4, 0.2, 1);
						});
					}
				}

				canBoogie = true;
			}
		}

		if (FlxG.sound.music.playing)
			Conductor.songPosition = FlxG.sound.music.time;
	}

	override function beatHit()
	{
		super.beatHit();

		if (!isEnding && canBoogie)
			bf.playAnim('deathLoop', true);

		FlxG.log.add('beat' + curBeat);
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			gameOverSound.play();
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					MusicBeatState.switchState(new PlayState());
				});
			});
		}
	}
}