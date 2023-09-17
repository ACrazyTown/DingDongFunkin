package;

import flixel.FlxSprite;
import openfl.Lib;

class KadeEngineData
{
	@:keep public static final commitHash:String = donut.macro.MacroUtil.getGitCommitHash();
	
    public static function initSave()
    {
		if (FlxG.save.data.downscroll == null)
			FlxG.save.data.downscroll = false;
			
		if (FlxG.save.data.accuracyDisplay == null)
			FlxG.save.data.accuracyDisplay = true;

		if (FlxG.save.data.offset == null)
			FlxG.save.data.offset = 0;

		if (FlxG.save.data.songPosition == null)
			FlxG.save.data.songPosition = false;

		if (FlxG.save.data.fps == null)
			FlxG.save.data.fps = false;

		if (FlxG.save.data.changedHit == null)
		{
			FlxG.save.data.changedHitX = -1;
			FlxG.save.data.changedHitY = -1;
			FlxG.save.data.changedHit = false;
		}

		if (FlxG.save.data.fpsCap == null)
			FlxG.save.data.fpsCap = 120;

		if (FlxG.save.data.frames == null)
			FlxG.save.data.frames = 10;

		if (FlxG.save.data.watermark == null)
			FlxG.save.data.watermark = true;

		if (FlxG.save.data.ghost == null)
			FlxG.save.data.ghost = true;

		if (FlxG.save.data.flashing == null)
			FlxG.save.data.flashing = true;

		if (FlxG.save.data.useShaders == null)
			FlxG.save.data.useShaders = true;

		if (FlxG.save.data.resetButton == null)
			FlxG.save.data.resetButton = false;
		
		if (FlxG.save.data.botplay == null)
			FlxG.save.data.botplay = false;

		if (FlxG.save.data.cpuStrums == null)
			FlxG.save.data.cpuStrums = false;

		if (FlxG.save.data.strumline == null)
			FlxG.save.data.strumline = false;

		if (FlxG.save.data.camzoom == null)
			FlxG.save.data.camzoom = true;

		if (FlxG.save.data.optimize == null)
			FlxG.save.data.optimize = false;
		
		if (FlxG.save.data.pauseCountdown == null)
			FlxG.save.data.pauseCountdown = true;

		if (FlxG.save.data.autoPause == null)
			FlxG.save.data.autoPause = true;

		if (FlxG.save.data.antialiasing == null)
			FlxG.save.data.antialiasing = true;

		if (FlxG.save.data.cutsceneSubtitles == null)
			FlxG.save.data.cutsceneSubtitles = true;

		if (FlxG.save.data.middlescroll == null)
			FlxG.save.data.middlescroll = false;

		if (FlxG.save.data.firstBoot == null)
			FlxG.save.data.firstBoot = true;

		if (FlxG.save.data.colorblindFilter == null)
			FlxG.save.data.colorblindFilter = "None";

		if (FlxG.save.data.cheatedUnlock == null)
			FlxG.save.data.cheatedUnlock = false;

		//FlxG.game.setFilters(FlxG.save.data.colorblindFilter != "None" ? [ColorblindFilter.get(ColorblindFilter.fromString(FlxG.save.data.colorblindFilter))] : []);
		//CoolUtil.setCamFilters(FlxG.game)
		CoolUtil.setGameFilters([]);

		FlxSprite.defaultAntialiasing = FlxG.save.data.antialiasing;
		FlxG.autoPause = FlxG.save.data.autoPause;

		Conductor.recalculateTimings();
		Main.setFPSCap(FlxG.save.data.fpsCap);
	}
}
