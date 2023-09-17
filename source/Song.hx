package;

import haxe.Json;
import lime.utils.Assets;

using StringTools;

typedef SwagSection =
{
	var sectionNotes:Array<Array<Dynamic>>;
	var lengthInSteps:Int;
	var mustHitSection:Bool;
	var isDuet:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
}

class Section
{
	public var sectionNotes:Array<Array<Dynamic>> = [];

	public var lengthInSteps:Int = 16;
	public var mustHitSection:Bool = true;

	/**
	 *	Copies the first section into the second section!
	 */
	public static var COPYCAT:Int = 0;

	public function new(lengthInSteps:Int = 16)
	{
		this.lengthInSteps = lengthInSteps;
	}
}

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var noteStyle:String;
	var stage:String;
	var validScore:Bool;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;

	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var gfVersion:String = '';
	public var noteStyle:String = '';
	public var stage:String = '';

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function exists(songName:String, folder:String):Bool
	{
		var folderLowercase:String = StringTools.replace(folder, " ", "-").toLowerCase();
		return Assets.exists(Paths.json('$folderLowercase/${songName.toLowerCase()}'));
	}

	public static function loadFromJson(jsonInput:String, folder:String):SwagSong
	{
		// pre lowercasing the folder name
		var folderLowercase:String = StringTools.replace(folder, " ", "-").toLowerCase();
		var rawJson = Assets.getText(Paths.json('$folderLowercase/${jsonInput.toLowerCase()}')).trim();

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}

	public static function getStage(song:String):String
	{
		return switch (song.toLowerCase())
		{
			case 'donut shop', 'allergy', 'halloween', 'shark rap', 'donut shop old', 'allergy old': 'donutshop';
			case 'abundance': 'void';
			case 'nuts': 'volcano-normal';
			case "dingdongdoom": "donutdodger";
			case 'allergic reaction': 'donutropolis';
			default: 'stage';
		}
	}
}
