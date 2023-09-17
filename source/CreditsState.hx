package;

#if (desktop && !hl)
import Discord.DiscordClient;
#end
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;

using StringTools;

/* COMPLETELY STOLEN FROM PSYCH ENGINE */

class CreditsState extends MusicBeatState
{
	override function create()
	{
		#if (desktop && !hl)
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		var bg = new FlxSprite().loadGraphic(Paths.image('menu/creditsImage'));
		add(bg);
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			//MusicBeatState.switchState(new MainMenuState());
			MusicBeatState.switchState(new MainMenuState());
		}
		
		if (controls.ACCEPT) {
			//CoolUtil.browserLoad(creditsStuff[curSelected][3]);
		}
		super.update(elapsed);
	}
}
