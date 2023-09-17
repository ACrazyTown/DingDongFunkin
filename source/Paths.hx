package;

import flixel.graphics.FlxGraphic;
import donut.load.LoadedAssets;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.Assets as OpenFlAssets;

using StringTools;

enum abstract FNFAsset(String)
{
	var FILE = "FILE";
	var TXT = "TXT";
	var XML = "XML";
	var JSON = "JSON";
	var CHAR = "CHAR";
	var SOUND = "SOUND";
	var MUSIC = "MUSIC";
	var IMAGE = "IMAGE";
	var FONT = "FONT";
	var INST = "INST";
	var VOICES = "VOICES";
	var VIDEO = "VIDEO";
}

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	public static var currentLevel(default, set):String;

	public static function assetPath(key:String, library:Null<String>, asset:FNFAsset, ?assetType:AssetType = TEXT, isPlayer:Bool = false):String
	{
		var ext:String = cast(asset, String).toLowerCase();
		var path:String = "";

		switch (asset)
		{
			case FILE:
				path = getPath(key, assetType, library);

			case TXT, XML, JSON:
				path = getPath('data/$key.$ext', TEXT, library);

			case CHAR:
				path = getPath('characters/$key.json', TEXT, library);

			case SOUND, MUSIC:
				var folder:String = (asset == SOUND) ? "sounds" : "music";
				path = getPath('$folder/$key.$SOUND_EXT', SOUND, library);

			case INST, VOICES:
				var songLowercase:String = StringTools.replace(key, " ", "-").toLowerCase();
				var file:String = '${isPlayer ? "BF" : "Dad"}_Voices.$SOUND_EXT';
				if (asset == INST)
					file = 'Inst.$SOUND_EXT';
				path = 'songs:assets/songs/$songLowercase/$file';

			case IMAGE:
				path = getPath('images/$key.png', IMAGE, library);

			case FONT:
				path = 'assets/fonts/$key';

			case VIDEO:
				if (FlxG.save.data.cutsceneSubtitles)
					key += "-sub";
		
				path = getPath('videos/$key.mp4', BINARY, library);

		}

		return path;
	}

	public static function voices(key:String, isPlayer:Bool = false):Dynamic
	{
		var path:String = assetPath(key, null, VOICES, null, isPlayer);

		if (LoadedAssets.exists(path, MUSIC))
			return LoadedAssets.get(path, MUSIC);

		return path;
	}

	public static function inst(key:String):Dynamic
	{
		var path:String = assetPath(key, null, INST);

		if (LoadedAssets.exists(path, MUSIC))
			return LoadedAssets.get(path, MUSIC);

		return path;
	}

	public static function music(key:String, ?library:String):Dynamic
	{
		var path:String = assetPath(key, library, MUSIC);

		if (LoadedAssets.exists(path, MUSIC))
			return LoadedAssets.get(path, MUSIC);

		return path;
	}

	public static function sound(key:String, ?library:String):Dynamic
	{
		var path:String = assetPath(key, library, SOUND);

		if (LoadedAssets.exists(path, SOUND))
			return LoadedAssets.get(path, SOUND);

		return path;
	}

	public static function image(key:String, ?library:String):Dynamic
	{
		var path:String = assetPath(key, library, IMAGE);

		if (LoadedAssets.exists(path, IMAGE))
		{
			return LoadedAssets.get(path, IMAGE);
		}

		return path;
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String):Dynamic
		return sound(key + FlxG.random.int(min, max), library);

	inline public static function font(key:String):String
		return assetPath(key, null, FONT);

	inline public static function json(key:String, ?library:String):String
		return assetPath(key, library, JSON);

	inline public static function char(key:String, ?library:String):String
		return assetPath(key, library, CHAR);

	inline public static function txt(key:String, ?library:String):String
		return assetPath(key, library, TXT);

	inline public static function video(key:String, ?library:String):String
		return assetPath(key, library, VIDEO);

	inline static public function getSparrowAtlas(key:String, ?library:String):FlxAtlasFrames
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), assetPath('images/$key.xml', library, FILE));
	}

	inline static public function getPackerAtlas(key:String, ?library:String):FlxAtlasFrames
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), assetPath('images/$key.txt', library, FILE));
	}

	static public function getPath(file:String, type:AssetType, library:Null<String>):String
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	inline static public function getLibraryPath(file:String, library = "preload"):String
	{
		return (library == "preload" || library == "default") ? getPreloadPath(file) : getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String):String
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String):String
	{
		return 'assets/$file';
	}

	static function set_currentLevel(value:String):String
	{
		currentLevel = value.toLowerCase();
		return value;
	}
}