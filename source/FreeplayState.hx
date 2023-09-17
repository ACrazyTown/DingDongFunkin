package;

import donut.load.LoadedAssets;
import donut.load.LoadManager;
import donut.GameData;
import sys.FileSystem;
import donut.load.LoadState;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.Assets;
import sys.thread.Thread;
import flixel.tweens.FlxTween;
import flixel.input.gamepad.FlxGamepad;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

#if (desktop && !hl)
import Discord.DiscordClient;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];
	var diffs:Array<String> = ["Easy", "Normal", "Nuts"];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var comboText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var combo:String = '';

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<TrackedSprite> = [];

	var bg:DingBg;

	var lockedTxt:FlxText;
	var lockedBg:FlxSprite;

	override function create():Void
	{
		#if debug
		songs.push(new SongMetadata("Test", 3, "ding"));
		#end

		for (data in GameData.data.weeks)
		{
			for (i in 0...data.songs.length)
			{
				var isLocked:Bool = false;
				#if BETA_BUILD
				var daName:String = data.songs[i].toLowerCase();
				if (daName == "cardiac" || daName == "shark rap")
					isLocked = true;
				#end

				songs.push(new SongMetadata(data.songs[i], data.week, data.icons[i], isLocked));
			}
		}

		bg = new DingBg();
		add(bg);

		#if (desktop && !hl)
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Freeplay Menu", null);
		#end

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);


		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, !songs[i].locked ? songs[i].songName : "??????");
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			if (!songs[i].locked)
			{
				var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
				icon.spriteTracker = songText;
				iconArray.push(icon);
				add(icon);
			}
			else
			{
				var lock:TrackedSprite = new TrackedSprite();
				lock.loadGraphic(Paths.image("lock"));
				lock.spriteTracker = songText;
				lock.xOffset = -170;
				lock.yOffset = 15;

				iconArray.push(lock);
				add(lock);
			}
		}

		scoreText = new FlxText(0, 5, 0, "PERSONAL BEST: 8888888", 32); // scaling hack
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT);
		scoreText.x = (FlxG.width - scoreText.width) - 5;

		diffText = new FlxText(scoreText.x, 0, 0, "< NORMAL >", 24);
		diffText.y = scoreText.y + scoreText.height + 5;
		diffText.font = scoreText.font;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 5, 0).makeGraphic(Std.int(scoreText.width) + 10, Std.int(scoreText.height + diffText.height + 15), 0xFF000000);
		scoreBG.alpha = 0.6;

		scoreText.text = "PERSONAL BEST: 0";

		comboText = new FlxText(diffText.x + 145, diffText.y, 0, "", 24);
		comboText.font = diffText.font;

		lockedTxt = new FlxText(0, 0, 0, "You need to beat Week %s to unlock this song!", 24);
		lockedTxt.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, RIGHT);
		lockedTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		lockedTxt.x = FlxG.width - lockedTxt.width - 5;
		lockedTxt.y = FlxG.height - lockedTxt.height - 5;
		lockedTxt.visible = false;
		add(lockedTxt);

		add(scoreBG);
		add(diffText);
		add(comboText);
		add(scoreText);

		changeSelection();
		changeDiff();

		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['dad'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var curSongLocked:Bool = grpSongs.members[curSelected].text != songs[curSelected].songName;

		if (!curSongLocked)
			lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		else
			lerpScore = 0;

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;
		comboText.text = combo + '\n';

		if (controls.UI_UP_P)
			changeSelection(-1);
		if (controls.UI_DOWN_P)
			changeSelection(1);
		//if (controls.UI_LEFT_P)
		//	changeDiff(-1);
		//if (controls.UI_RIGHT_P)
		//	changeDiff(1);

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT)
		{
			// not unloked i think
			if (curSongLocked)
			{
				FlxG.sound.play(Paths.sound("locked"));
				return;
			}

			// adjusting the song name to be compatible
			var songFormat = StringTools.replace(songs[curSelected].songName, " ", "-");
			var poop:String = Highscore.formatSong(songFormat, curDifficulty);

			if (Song.exists(poop, songs[curSelected].songName))
			{
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;
				PlayState.storyWeek = songs[curSelected].week;

				LoadState.loadAndSwitchState(new PlayState());
			}
			else
			{
				MusicBeatState.switchState(new ChartingState(songs[curSelected].songName));
			}
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;
		
		if (curDifficulty < 0)
			curDifficulty = diffs.length - 1;
		if (curDifficulty >= diffs.length)
			curDifficulty = 0;

		// adjusting the highscore song name to be compatible (changeDiff)
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);

		var diff:String = CoolUtil.difficultyFromInt(curDifficulty, true).toUpperCase();
		if (diff == "NORMAL")
			diffText.text = "< NORMAL >";
		else
			diffText.text = '<  $diff  >';
	}

	function changeSelection(change:Int = 0)
	{
		// NGio.logEvent('Fresh');
		if (change != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;
		
		// adjusting the highscore song name to be compatible (changeSelection)
		// would read original scores if we didn't change packages
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");

		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
			iconArray[i].alpha = 0.6;

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
		}

		if (songs[curSelected].locked)
		{
			lockedTxt.visible = true;
			#if BETA_BUILD
			lockedTxt.text = 'Song not implemented';
			#else
			lockedTxt.text = 'You need to beat Week ${songs[curSelected].week-1} to unlock this song!';
			#end
		}
		else 
			lockedTxt.visible = false;

		//changeDiff(); // prevent nonexisting diffs from 'carrying over'
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var locked:Bool = false;

	public function new(song:String, week:Int, songCharacter:String, ?locked:Bool = false)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.locked = locked;
	}
}
