package;

import Song.SwagSong;

/**
 * ...
 * @author
 */

typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

class Conductor
{
	public static var bpm(default, set):Float = 100;
	public static var crochet(default, set):Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds
	public static var songPosition:Float = 0;
	public static var lastSongPos:Float;
	public static var offset:Float = 0;

	public static var safeFrames(default, set):Int = 10;
	public static var safeZoneOffset:Float = (safeFrames / 60) * 1000; // is calculated in create(), is safeFrames in milliseconds
	public static var timeScale:Float = Conductor.safeZoneOffset / 166;

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	public static function recalculateTimings():Void
	{
		safeFrames = FlxG.save.data.frames;
		safeZoneOffset = Math.floor((Conductor.safeFrames / 60) * 1000);
		timeScale = Conductor.safeZoneOffset / 166;
	}

	public static function mapBPMChanges(song:SwagSong):Void
	{
		bpmChangeMap = [];

		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;

		for (i in 0...song.notes.length)
		{
			if (song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
			{
				curBPM = song.notes[i].bpm;
				var event:BPMChangeEvent = 
				{
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};

				bpmChangeMap.push(event);
			}

			var deltaSteps:Int = song.notes[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}

		trace("new BPM map BUDDY " + bpmChangeMap);
	}

	private static function set_bpm(Value:Float):Float
	{
		bpm = Value;
		crochet = ((60 / bpm) * 1000);
		return Value;
	}

	private static function set_crochet(Value:Float):Float 
	{
		crochet = Value;
		stepCrochet = crochet / 4;
		return Value;
	}

	private static function set_safeFrames(Value:Int):Int 
	{
		safeFrames = Value;
		safeZoneOffset = (safeFrames / 60) * 1000;
		return Value;
	}
}
