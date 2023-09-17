package;

import PlayState.PlayStateChangeables;

using StringTools;

class Highscore
{
	public static var songScores:Map<String, Int> = new Map();
	public static var songCombos:Map<String, String> = new Map();
	
	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0):Void
	{
		if (PlayStateChangeables.botPlay || FlxG.save.data.botplay)
		{
			trace("Not saving score with BOTPLAY!");
			return;
		}

		var daSong:String = formatSong(song, diff);
		if (songScores.exists(daSong) && songScores.get(daSong) < score || !songScores.exists(daSong))
			setScore(daSong, score);
	}

	public static function saveCombo(song:String, combo:String, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);

		if (PlayStateChangeables.botPlay || FlxG.save.data.botplay)
		{
			trace("Not saving combo with BOTPLAY!");
			return;
		}

		if (songCombos.exists(daSong) && getComboInt(songCombos.get(daSong)) < getComboInt(combo) || !songCombos.exists(daSong))
			setCombo(daSong, combo);
	}

	public static function saveWeekScore(week:Int = 1, score:Int = 0, ?diff:Int = 0):Void
	{
		if (PlayStateChangeables.botPlay || FlxG.save.data.botplay)
		{
			trace("Not saving score with BOTPLAY!");
			return;
		}

		var daWeek:String = formatSong('week' + week, diff);

		if (songScores.exists(daWeek) && songScores.get(daWeek) < score || !songScores.exists(daWeek))
			setScore(daWeek, score);
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}

	static function setCombo(song:String, combo:String):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songCombos.set(song, combo);
		FlxG.save.data.songCombos = songCombos;
		FlxG.save.flush();
	}

	public static function formatSong(song:String, diff:Int):String
	{
		var diffStr:String = (diff == 1) ? "" : CoolUtil.difficultyFromInt(diff).toLowerCase();
		return (diff == 1) ? '$song' : '$song-$diffStr';
	}

	static function getComboInt(combo:String):Int
	{
		var val:Int = 0;

		switch (combo)
		{
			case 'SDCB': val = 1;
			case 'FC': val = 2;
			case 'GFC': val = 3;
			case 'SFC': val = 4;
		}

		return val;
	}

	public static function getScore(song:String, diff:Int):Int
	{
		if (!songScores.exists(formatSong(song, diff)))
			setScore(formatSong(song, diff), 0);

		return songScores.get(formatSong(song, diff));
	}

	public static function getCombo(song:String, diff:Int):String
	{
		if (!songCombos.exists(formatSong(song, diff)))
			setCombo(formatSong(song, diff), '');

		return songCombos.get(formatSong(song, diff));
	}

	public static function getWeekScore(week:Int, diff:Int):Int
	{
		if (!songScores.exists(formatSong('week' + week, diff)))
			setScore(formatSong('week' + week, diff), 0);

		return songScores.get(formatSong('week' + week, diff));
	}

	public static function load():Void
	{
		if (FlxG.save.data.songScores != null)
			songScores = FlxG.save.data.songScores;

		if (FlxG.save.data.songCombos != null)
			songCombos = FlxG.save.data.songCombos;
	}
}
