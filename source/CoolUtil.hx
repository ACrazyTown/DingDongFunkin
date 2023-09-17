package;

import donut.load.LoadedAssets;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.input.keyboard.FlxKey;
import lime.app.Application;
import donut.shader.ColorblindFilter;
import openfl.filters.BitmapFilter;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import openfl.Assets;
import lime.utils.Assets as LimeAssets;
import haxe.io.Path;

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ["Easy", "Normal", "Hard"];
	public static var difficultyArrayDis:Array<String> = ["Easy", "Normal", "Nuts"];

	inline public static function difficultyFromInt(difficulty:Int, display:Bool = false):String
		return display ? difficultyArrayDis[difficulty] : difficultyArray[difficulty];

	inline public static function coolTextFile(path:String):Array<String>
	{
		return [for (i in LimeAssets.getText(path).trim().split("\n")) i.trim()];
	}

	inline public static function camLerpShit(ratio:Float):Float
	{
		return FlxG.elapsed / (1 / 6) * ratio;
	}

	inline public static function coolLerp(a:Float, b:Int, ratio:Float):Float
	{
		return a + camLerpShit(ratio) * (b - a);
	}
	
	public static function setCamFilters(cameras:Array<FlxCamera>, ?filters:Array<BitmapFilter>):Void
	{
		if (cameras == null || cameras == [])
			cameras = [FlxG.camera]; // get FlxG.camera because I CANT APPLY FILTER TO NOTHING

		if (filters == null)
			filters = [];

		if (FlxG.save.data.colorblindFilter != null && FlxG.save.data.colorblindFilter != "None")
			filters.push(ColorblindFilter.get(ColorblindFilter.fromString(FlxG.save.data.colorblindFilter)));

		for (camera in cameras)
		{
			if (camera != null)
				camera.setFilters(filters);
		}
	}

	public static function pushCamFilters(cameras:Array<FlxCamera>, ?filters:Array<BitmapFilter>):Void
	{
		if (cameras == null || cameras == [])
			cameras = [FlxG.camera];

		if (filters == null)
			filters = [];

		@:privateAccess
		for (camera in cameras)
		{
			if (camera != null)
			{
				if (camera._filters == null || camera._filters == [])
					setCamFilters([camera], filters);

				for (filter in filters)
				{
					if (filter != null)
					{
						@:privateAccess
						camera._filters.push(filter);
					}
				}
			}
		}
	}

 	public static function setGameFilters(filters:Array<BitmapFilter>):Void
	{
		if (filters == null)
			filters = [];

		if (FlxG.save.data.colorblindFilter != null && FlxG.save.data.colorblindFilter != "None")
			filters.push(ColorblindFilter.get(ColorblindFilter.fromString(FlxG.save.data.colorblindFilter)));

		FlxG.game.setFilters(filters);
	}

	public static function pushGameFilters(filters:Array<BitmapFilter>):Void
	{
		if (filters == null)
			filters = [];

		for (filter in filters)
		{
			if (filter != null)
			{
				@:privateAccess
				FlxG.game._filters.push(filter);
			}
		}
	}

	inline public static function convertScore(noteDiff:Float):Int
	{
		return switch (Ratings.calculateRating(noteDiff).toLowerCase())
		{
			case 'shit': -300;
			case 'bad': 0;
			case 'good': 200;
			case 'sick': 350;
			case _: 350; // UNKNOWN BRUH 
		}
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float
	{
		return Math.max(min, Math.min(max, value));
	}

	inline public static function website(URL:String):Void
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [URL, "&"]);
		#else
		FlxG.openURL(URL);
		#end
	}

	public static function manualCrash(?message:String, ?error:String, ?title:String = "DingDong's Funkin' 2.0"):Void
	{
		#if debug
		return;
		#else

		if (message == "" || message == null)
			message = "An error occured and DingDong's Funkin' 2.0 has crashed.\nPlease report this error to the DingDong's Funkin' GitHub repository:\n" + error;

		Application.current.window.alert(message, title);
		Sys.exit(0);
		#end
	}

	public static function formatKey(key:FlxKey):String
	{
		return switch (key)
		{
			case NUMPADMULTIPLY: "NUMPADMULT";
			case NONE: "---";
			default: key.toString();
		}
	}

	inline public static function songTypeFromPath(path:String):String
	{
		return switch (Path.withoutDirectory(Path.withoutExtension(path)).toLowerCase())
		{
			case "inst": "inst";
			case "bf_voices": "vocalbf";
			case "dad_voices": "vocaldad";
			case _: "";
		}
	}

	public static function combineFrames(primary:FlxFramesCollection, secondary:Array<FlxFramesCollection>):FlxFramesCollection
	{
		if (primary == null)
			return null;

		if (secondary == null)
			return primary;

		var newCollection:FlxFramesCollection = primary;

		for (atlas in secondary)
		{
			if (atlas != null)
			{
				atlas.parent.persist = true;
				LoadedAssets.atlasParentCache.push(atlas.parent);

				for (frame in atlas.frames)
				{
					if (frame != null)
						newCollection.pushFrame(frame);
				}
			}
		}

		return newCollection;
	}
}
