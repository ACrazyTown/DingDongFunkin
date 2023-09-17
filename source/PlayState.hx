package;

import flixel.util.FlxSignal;
import flixel.util.FlxDestroyUtil;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxStringUtil;
import flixel.addons.effects.FlxTrail;
import donut.shader.CAShader;
import flixel.FlxBasic;
import donut.SyncedSprite;
import donut.shader.ColorSwap;
import openfl.filters.ShaderFilter;
import flixel.addons.transition.FlxTransitionableState;
import donut.GameData;
import donut.load.LoadManager;
import donut.load.LoadedAssets;
import donut.load.LoadState;
import donut.achievement.AchievementData;
import openfl.utils.Assets;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import flixel.input.keyboard.FlxKey;
import openfl.Lib;
import Song.SwagSection;
import Song.SwagSong;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;

#if desktop
#if !hl
import Discord.DiscordClient;
#end
import Sys;
import sys.io.File;
import sys.FileSystem;
import sys.thread.Thread;
#end

using StringTools;

class PlayStateChangeables
{
	public static var useDownscroll:Bool = false;
    public static var safeFrames:Int = Conductor.safeFrames;
    public static var botPlay:Bool = false;
    public static var optimize:Bool = false;
	public static var middlescroll:Bool = false;

	public static function update():Void
	{
		useDownscroll = FlxG.save.data.downscroll;
		safeFrames = FlxG.save.data.frames;
		botPlay = FlxG.save.data.botplay;
		optimize = FlxG.save.data.optimize;
		middlescroll = FlxG.save.data.middlescroll;
	}
}

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;
	public static var songMultiplier:Float = 1.0;

	public static var SONG:SwagSong = null;
	public static var curStage:String = "stage";
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var weekScore:Int = 0;
	private var curSong:String = "";

	private var originalSpeed:Float = 1.0;
	public var scrollSpeed(default, set):Float = 1.0;

	private var zoomOnBeat:Bool = true;
	private var gameZoomMult:Float = 1;
	private var hudZoomMult:Float = 1;
	public static var ratingSizeMult:Float = 0.8; // 1.25 = 0.8

	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public var songScore:Int = 0;
	public static var highestCombo:Int = 0;

	public static var deaths:Int = 0;
	public static var misses:Int = 0;
	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;

	private var inCutscene:Bool = false;
	public static var seenCutscene:Bool = false;
	public static var offsetTesting:Bool = false;

	private var songLength:Float = 0;
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var dialogue:Array<String> = [];
	public static var noteBools:Array<Bool> = [false, false, false, false];

	#if (desktop && !hl)
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	private var dadVocals:FlxSound;
	private var bfVocals:FlxSound;

	public static var dad:Character = null;
	public static var gf:Character = null;
	public static var boyfriend:Boyfriend = null;

	public var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];
	private var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var strumLine:FlxSprite;
	public static var strumLineNotes:FlxTypedGroup<StrumNote> = null;
	public static var playerStrums:FlxTypedGroup<StrumNote> = null;
	public static var cpuStrums:FlxTypedGroup<StrumNote> = null;

	public static var stageZoom:Float = 1.05;
	public static var defaultCamZoom:Float = 1.05;

	public var camFollowPos:FlxPoint;
	private var camFollow:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private var camZooming:Bool = false;
	private var charCamPos:Map<String, Array<Float>> = [
		"ding" => [150, -50],
		"ding-happy" => [150, -50],
		"ocean" => [150, -50],
		"lapis" => [0, 0]
	];

	public var health:Float = 1;

	private var combo:Int = 0;
	private var gfSpeed:Int = 1;

	private var totalPlayedNotes:Int = 0;
	private var hitNotes:Float = 0;
	public var accuracy:Float = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var songPositionBar:Float = 0;

	var songTimeBar:FlxBar;
	var songTimeText:FlxText;
	var songLengthText:FlxText;

	private var scoreTxt:FlxText;
	private var subtitleText:FlxText;
	private var botPlayTxt:FlxText;
	private var botPlaySine:Float = 0;

	public var iconP1:HealthIcon; //making these public again because i may be stupid
	public var iconP2:HealthIcon; //what could go wrong?

	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	
	public var videoOnComplete:FlxSignal;
	private var gameOverlaySprite:FlxSprite;

	// mfw ding mod stuff
	var hueShader:ColorSwap;
	var useShaders:Bool = false;

	var bgGroup:FlxTypedGroup<StageSprite>;
	var bgFrontGroup:FlxTypedGroup<StageSprite>;

	var lapisfox:StageSprite;
	var appleShopSign:StageSprite;

	var oceanWalkStep:Int = 0;
	var oceanInPos:Bool = false;
	var ocean:FlxSprite;
	var micah:StageSprite;
	var donutShop:StageSprite;
	var cloud:StageSprite;

	var sun:FlxSprite;
	var coolSky:FlxSprite;
	var backbuildings:FlxSprite;
	var frontBuildings:FlxSprite;
	var grassFloor:FlxSprite;

	//var atlasChar:FlxAnimate;
	var syncedChar:SyncedSprite;
	var dingBoppers:StageSprite;

	// DRAIN
	var donutDrain:Bool = false;
	var donutDps:Float = 0.001;
	var drainTime:Float = 5.0;

	var flyThing:Float = 0;

	var micahWalkDone:Bool = false;
	var micahStartBeat:Int = 0;
	// END OF DING

	var dadCanDamage:Bool = false;

	var canViewCutscene:Bool;

	var binds:Array<Array<FlxKey>> = [];

	override function add(object:FlxBasic):FlxBasic
	{
		if (gameOverlaySprite != null && (members != null && members.contains(gameOverlaySprite)))
			return super.insert(members.indexOf(gameOverlaySprite), object);
		else
			return super.add(object);
	}

	override public function create():Void
	{
		instance = this;

		#if debug
		FlxG.console.registerClass(PlayState);
		FlxG.console.registerClass(PlayStateChangeables);
		FlxG.console.registerFunction("swapDad", (char:String) -> 
		{
			if (dad != null)
			{
				var ox = dad.x;
				var oy = dad.y;

				remove(dad);
				dad = null;

				dad = new Character(ox, oy, char);
				dad.updateHitbox();
				add(dad);
			}
			else
				FlxG.log.error("BRHU");
		});
		#end
		
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		PlayStateChangeables.update();

		sicks = 0;
		goods = 0;
		bads = 0;
		shits = 0;
		misses = 0;
		highestCombo = 0;

		binds = [
			KeyBinds.keyBinds.get("note_left"), 
			KeyBinds.keyBinds.get("note_down"),
			KeyBinds.keyBinds.get("note_up"),
			KeyBinds.keyBinds.get("note_right")
		];

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camHUD.alpha = 0;
		camOther = new FlxCamera();
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		CustomFadeTransition.nextCamera = camOther;
		//FlxCamera.defaultCameras = [camGame];

		persistentUpdate = persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('donut-shop', 'donut-shop');

		// hard code.
		SONG.noteStyle = "ding";
		curSong = SONG.song;

		dadCanDamage = (storyDifficulty > 1);
		
		Conductor.mapBPMChanges(SONG);
		Conductor.bpm = SONG.bpm;
		Conductor.songPosition = -5000;

		canViewCutscene = #if (debug || FREEPLAY_UNLOCK || BETA_BUILD) true #else (isStoryMode && !PlayStateChangeables.optimize) #end;

		//dialogue shit
		dialogue = Assets.exists(Paths.txt(curSong.toLowerCase() + "/" + "dialogue")) ? CoolUtil.coolTextFile(Paths.txt(curSong.toLowerCase() + "/" + "dialogue")) : [];

		var gfType:String = (SONG.gfVersion == null) ? "gf" : SONG.gfVersion;

		buildStage(Song.getStage(SONG.song));
		
		gf = new Character(400, 130, gfType);
		dad = new Character(100, 100, SONG.player2);

		var additionalAtlases:Array<FlxFramesCollection> = [];
		if (curSong.toLowerCase() == "forgotten" || curSong.toLowerCase() == "dingdongdoom")
			additionalAtlases = [
				//Paths.getSparrowAtlas("characters/bf/hitdodge", "shared")
				FlxAtlasFrames.fromSparrow("shared:assets/shared/images/characters/bf/hitdodge.png", "shared:assets/shared/images/characters/bf/hitdodge.xml")
			];

		boyfriend = new Boyfriend(770, 450, SONG.player1, additionalAtlases);

		gf.scrollFactor.set(0.95, 0.95);
		dad.updateHitbox();

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
			case 'ding':
				dad.y += 200;
				dad.x += 80;
			case 'ding-worried':
				dad.y += 190;
				dad.x += 50;
			case 'lapis':
				dad.x += 100;	
				dad.y += 50;
			case 'ocean':
				dad.x += 100;
				dad.y += 300;
		}

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'donutshop':
				boyfriend.x += 280;
				boyfriend.y += 20;
				gf.x += 20;
				if (curSong.toLowerCase() == "shark rap")
					gf.x += 300;

			case 'void':
				boyfriend.x += 280;
				boyfriend.y += 20;
				gf.x += 20;

			case "donutdodger":
				var trail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				insert(members.indexOf(dad), trail);

				var trailBf = new FlxTrail(boyfriend, null, 4, 24, 0.3, 0.069);
				insert(members.indexOf(boyfriend), trailBf);

			case 'volcano-normal':
				boyfriend.x += 170;

			case 'donutropolis':	
				dad.setPosition(600, -220);	
				boyfriend.setPosition(1232, -161.0);	
				gf.setPosition(745.95, -540);
		}

		if (!PlayStateChangeables.optimize)
		{
			add(gf);
			add(dad);
			add(boyfriend);

			bgFrontGroup = new FlxTypedGroup<StageSprite>();
			add(bgFrontGroup);

			// additional layering owo
			switch (curStage)
			{
				case "donutshop":
					if (curSong.toLowerCase() == "halloween")
					{
						//syncedAtlasChar = new FlxSyncedAnim(dad.x + 100, dad.y + 300, Paths.embeddedAtlas(curSong.toLowerCase(), "oceanrant"), {Antialiasing: true});
						//syncedAtlasChar.anim.addBySymbol("talk", "OCEAN halloween rant", 24);
						//add(syncedAtlasChar);

						syncedChar = new SyncedSprite(dad.x-19, dad.y-4);
						syncedChar.frames = Paths.getSparrowAtlas("oceanrant", "donutshop");
						syncedChar.animation.addByPrefix("talk", "OCEAN halloween rant", 24, false);
						syncedChar.visible = false;
						add(syncedChar);
					}

				case "donutropolis":
					dingBoppers = new StageSprite(210, 24, "boppers", "donutropolis", ["bop people instance", "bop people copy"], false);
					dingBoppers.setGraphicSize(Std.int(dingBoppers.width * 0.83));
					dingBoppers.updateHitbox();
					bgFrontGroup.add(dingBoppers);
			}
		}
		
		hueShader = new ColorSwap();/*Shaders.create("colorswap");*/

		strumLine = new FlxSprite(0, PlayStateChangeables.useDownscroll ? (FlxG.height - 165) : 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<StrumNote>();
		cpuStrums = new FlxTypedGroup<StrumNote>();
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		
		var noteSplash:NoteSplash = new NoteSplash(100, 100);
		grpNoteSplashes.add(noteSplash);
		noteSplash.alpha = 0;
		add(grpNoteSplashes);

		// camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
		camFollowPos = new FlxPoint();
		camFollow = new FlxObject(0, 0, 1, 1);

		if (curSong.toLowerCase() == "nuts")
			camFollowPos.set(dad.getMidpoint().x + 280, dad.getMidpoint().y - 35);
		else
			camFollowPos.set(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y + 50);

		camFollow.setPosition(camFollowPos.x, camFollowPos.y);

		if (prevCamFollow != null)
		{
			camFollowPos = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollowPos);
		FlxG.worldBounds.set(0, 0, FlxG.width * 2, FlxG.height * 2);
		FlxG.fixedTimestep = false;

		generateSong();

		// from dot-engine poggers

		healthBarBG = new FlxSprite(0, PlayStateChangeables.useDownscroll ? 50 : FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.active = false;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, 'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(dad.accentColor, boyfriend.accentColor);

		if (FlxG.save.data.songPosition)
		{
			songTimeBar = new FlxBar(0, 0, LEFT_TO_RIGHT, FlxG.width, 10, this, "songTime");
			songTimeBar.numDivisions = 1000;
			songTimeBar.createFilledBar(FlxColor.TRANSPARENT, 0xFF31B0D1);

			songTimeText = new FlxText(5, 15, 0, "0:00", 20);
			songTimeText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT);
			songTimeText.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
			songTimeText.scrollFactor.set();

			songLengthText = new FlxText(0, 32, 0, "0:00", 20);
			songLengthText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, RIGHT);
			songLengthText.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
			songLengthText.x = FlxG.width - songLengthText.width - 5;
			songLengthText.scrollFactor.set();

			if (PlayStateChangeables.useDownscroll)
			{
				songTimeBar.y = FlxG.height - songTimeBar.height;
				songTimeText.y = songTimeBar.y - songTimeText.height - 5;
				songLengthText.y = songTimeText.y;
			}
		}

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);

		scoreTxt = new FlxText(10, 0, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT);
		scoreTxt.fieldWidth = 420;
		scoreTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		scoreTxt.scrollFactor.set();
		scoreTxt.text = Ratings.calculateRanking(songScore, accuracy);
		scoreTxt.y = PlayStateChangeables.useDownscroll ? 10 : FlxG.height - scoreTxt.height - 10;

		botPlayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0, "BOTPLAY", 20);
		botPlayTxt.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botPlayTxt.scrollFactor.set();
		botPlayTxt.borderSize = 4;
		botPlayTxt.borderQuality = 2;
		botPlayTxt.cameras = [camHUD];

		subtitleText = new FlxText(0, 0, 0, "error", 36);
		subtitleText.screenCenter();
		subtitleText.y += 180;
		subtitleText.setFormat("VCR OSD Mono", 36, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		subtitleText.borderSize = 4;
		subtitleText.scrollFactor.set();
		subtitleText.visible = false;
		add(subtitleText);

		if (!PlayStateChangeables.botPlay)
		{
			add(healthBarBG);
			add(healthBar);
			add(iconP1);
			add(iconP2);
		}
		else
		{
			add(botPlayTxt);
		}

		if (FlxG.save.data.songPosition)
		{
			add(songTimeText);
			add(songLengthText);
			add(songTimeBar);
		}

		add(scoreTxt);

		grpNoteSplashes.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];

		if (!PlayStateChangeables.botPlay)
		{
			healthBar.cameras = [camHUD];
			healthBarBG.cameras = [camHUD];
			iconP1.cameras = [camHUD];
			iconP2.cameras = [camHUD];
		}

		if (FlxG.save.data.songPosition)
		{
			songTimeText.cameras = [camHUD];
			songLengthText.cameras = [camHUD];
			songTimeBar.cameras = [camHUD];
		}

		scoreTxt.cameras = [camHUD];
		subtitleText.cameras = [camHUD];

		gameOverlaySprite = new FlxSprite(FlxG.width * -2, FlxG.height * -2).makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.BLACK);
		gameOverlaySprite.alpha = 0;
		add(gameOverlaySprite);

		oceanWalkStep = FlxG.random.int(18, 38);
		micahStartBeat = FlxG.random.int(164, 355);

		startingSong = true;

		switch (curSong.toLowerCase())
		{
			case "nuts":
				if (canViewCutscene)
					gameOverlaySprite.alpha = 0;

			case "forgotten" | "dingdongdoom":
				boyfriend.animation.addByPrefix("hit", "BF hit", 24, false);
				boyfriend.animation.addByPrefix("dodge", "boyfriend dodge", 24, false);
				boyfriend.addOffset("hit", 14, 18);
				boyfriend.addOffset("dodge", -10, -16);

			case "test":
				if (!Main.debugMode)
					Main.achv.trigger("testsong");

		}

		// FIX THE GAME NOT STARTING BECAUSE OF THIS JUMBLE
		if (canViewCutscene)
		{
			switch (curSong.toLowerCase())
			{
				case "donut shop":
						playVideoCutscene("donut-shop");

				case "nuts":
						playVideoCutscene("nuts");
					
				case "shark rap":
						sharkRapCutscene();

				default:
					startCountdown();
			}
		}
		else
		{
			startCountdown();
		}


		#if (desktop && !hl)
		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = CoolUtil.difficultyFromInt(storyDifficulty);
		iconRPC = SONG.player2;

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
			detailsText = "Story Mode: Week " + storyWeek;
		else
			detailsText = "Freeplay";

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText + " " + curSong + " (" + storyDifficultyText + ") " + Ratings.generateLetterRank(), "\nAcc: " + FlxMath.roundDecimal(accuracy, Ratings.accuracyPrecision) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
		#end

		scrollSpeed = SONG.speed;
		originalSpeed = scrollSpeed;

		FlxTransitionableState.skipNextTransIn = false;
		FlxTransitionableState.skipNextTransOut = false;

		super.create();
	}

	function buildStage(stage:String):Void
	{
		if (stage == null)
			return;

		bgGroup = new FlxTypedGroup<StageSprite>();
		add(bgGroup);

		if (!PlayStateChangeables.optimize)
		{
			switch (stage)
			{
				case 'stage':
				{
					defaultCamZoom = stageZoom = 0.9;
					curStage = 'stage';

					var bg:StageSprite = new StageSprite(-600, -200, "stageback", null, null, false, 0.9, 0.9);

					var stageFront:StageSprite = new StageSprite(-650, 600, "stagefront", null, null, false, 0.9, 0.9);
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();

					var stageCurtains:StageSprite = new StageSprite(-500, -300, "stagecurtains", null, null, false, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();

					bgGroup.add(bg);
					bgGroup.add(stageFront);
					bgGroup.add(stageCurtains);
				}
				case 'donutshop':
				{
					defaultCamZoom = stageZoom = 0.85;
					curStage = 'donutshop';
	
					//var bg:StageSprite = new StageSprite(-FlxG.width / 2, -FlxG.height / 2, null, null, null, false);
					//bg.makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFBEFFFD);

					camGame.bgColor = 0xFFBEFFFD;

					donutShop = new StageSprite(0, 0, "donutShop", "donutshop", ["donut shop"], false, 0.9, 0.9);
					donutShop.screenCenter(Y);
					donutShop.x -= 120;
					donutShop.y += 140;

					var bgGround:StageSprite = new StageSprite(-520, 683, "stageGround", "donutshop", null, false, 0.9, 0.9);
	
					cloud = new StageSprite(800, -180, "cloud", "donutshop", null, false, 0.9, 0.9);
	
					micah = new StageSprite(-520, ((FlxG.height / 2) + 5), "micah_walk", "donutshop", ["micah walk"], true);
					micah.visible = false;
	
					lapisfox = new StageSprite(1625, 200, "lapisfox", "donutshop", ["Lapis Fox Dance"], false);

					appleShopSign = new StageSprite(-240, 0, "appleshopsign", "donutshop", ["lapis apple shop sign"], false);
					appleShopSign.screenCenter(Y);
					appleShopSign.y += 260;

					bgGroup.add(donutShop);
					bgGroup.add(bgGround);
					bgGroup.add(cloud);
					bgGroup.add(lapisfox);
					bgGroup.add(appleShopSign);
	
					lapisfox.visible = (curSong.toLowerCase() != "shark rap");

					switch (curSong.toLowerCase())
					{
						case "shark rap":
							donutShop.x += 1800;
							appleShopSign.x += 1800;

						case "allergy":
							ocean = new FlxSprite(-620, lapisfox.y + 120);
							ocean.frames = Paths.getSparrowAtlas("ocean", "donutshop");
							ocean.animation.addByPrefix("dance", "Ocean Dance", 24, false);
							ocean.animation.addByPrefix("walk", "ocean walk", 24, true);
							ocean.active = false;
							add(ocean);
					}

					bgGroup.add(micah);
				}

				case 'void':
				{
					defaultCamZoom = stageZoom = 0.85;
					curStage = 'void';

					var bg:StageSprite = new StageSprite((-643.15 / 1.5), (-466.85 / 1.5), "gradBG", "void", null, false, 0.3, 0.3);
					var ground:StageSprite = new StageSprite((-1326.6 / 1.5), (893.3 / 1.5), "gridFloor", "void", null, false);

					bgGroup.add(bg);
					bgGroup.add(ground);
				}

				case 'volcano-normal':
				{
					defaultCamZoom = stageZoom = 0.7;
					curStage = 'volcano-normal';
	
					camGame.bgColor = 0xFFB7D0E8;

					var ground:StageSprite = new StageSprite(-1800, -465, "volcano_Normal", "volcano", null, false);

					bgGroup.add(ground);
				}

				case 'donutropolis':
				{
					defaultCamZoom = stageZoom = 0.85;
					curStage = 'donutropolis';

					// 0xFF000033
					coolSky = new FlxSprite(-500, -500).makeGraphic(FlxG.width * 2, FlxG.height, 0xFFBCBEFB);
					coolSky.active = false;
					add(coolSky);

					sun = new FlxSprite(785.6, -528.4);
					sun.loadGraphic(Paths.image("bonus/bigcoorcle", "donutropolis"));
					//sun.setGraphicSize(Std.int(sun.width / 1.5), Std.int(sun.height / 1.5));
					sun.updateHitbox();
					sun.visible = false;
					add(sun);

					backbuildings = new FlxSprite(0, -512);
					backbuildings.frames = Paths.getSparrowAtlas("backbuildings", "donutropolis");
					backbuildings.animation.addByPrefix("day", "gayo instance 20000", 24, false);
					backbuildings.animation.addByPrefix("night", "gayo instance 10000", 24, false);
					//backbuildings.setGraphicSize(Std.int(2030.75 / 1.5), Std.int(691.25 / 1.5));
					backbuildings.updateHitbox();
					//backbuildings.screenCenter(X);
					backbuildings.scrollFactor.set(0.7, 0.7);
					add(backbuildings);

					frontBuildings = new FlxSprite(-120, -600);
					frontBuildings.frames = Paths.getSparrowAtlas("frontbuildings", "donutropolis");
					frontBuildings.animation.addByPrefix("day", "city bg instance", 0, false);
					frontBuildings.animation.addByPrefix("night", "city bg copy instance", 0, false);
					//frontBuildings.setGraphicSize(Std.int(2785.29 / 1.5), Std.int(947.25 / 1.5));
					//frontBuildings.screenCenter(X);
					frontBuildings.updateHitbox();
					frontBuildings.scrollFactor.set(0.9, 0.9);
					add(frontBuildings);

					grassFloor = new FlxSprite(100, 24);
					grassFloor.frames = Paths.getSparrowAtlas("floor", "donutropolis");
					grassFloor.animation.addByPrefix("day", "doink", 24, false);
					grassFloor.animation.addByPrefix("night", "grassy grass", 24, false);
					//grassFloor.setGraphicSize(Std.int(2070.70 / 1.5), Std.int(939.75 / 1.5));
					grassFloor.updateHitbox();
					add(grassFloor);

					backbuildings.animation.play("day");
					frontBuildings.animation.play("day");
					grassFloor.animation.play("day");
				}
				case "donutdodger": 
				{
					defaultCamZoom = stageZoom = 0.8;
					curStage = "donutdodger";
					camGame.bgColor = 0xFF33083B;

				}
				default:
				{
					defaultCamZoom = stageZoom = 0.9;
					curStage = 'stage';

					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					add(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					add(stageFront);

					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;

					add(stageCurtains);
				}
			}
		}

		if (PlayStateChangeables.optimize)
			camGame.bgColor = 0;
			
	}

	function sharkRapCutscene():Void
	{
		/*
		if (seenCutscene)
			startCountdown();

		inCutscene = true;

		FlxTween.tween(gameOverlaySprite, {alpha: 0}, 1.5);
		FlxG.camera.zoom = defaultCamZoom * 1.2;

		FlxG.sound.playMusic(Paths.music('sneak'), 0);
		FlxG.sound.music.fadeIn(5, 0, 0.35);
 
		lapisfox.exists = false;

		dad.visible = false;
		boyfriend.visible = false;
		gf.visible = false;

		camFollow.setPosition(appleShopSign.x + 120, appleShopSign.y + 60);
		FlxG.camera.zoom *= 1.49;

		//FlxG.camera.follow(null);

		new FlxTimer().start(3, function(tmr:FlxTimer)
		{
			FlxG.sound.music.fadeOut(3.5, 0);
			//FlxTween.tween(FlxG.camera, {scroll: FlxPoint.get(FlxG.camera.x, -920)}, 5, {ease: FlxEase.quadInOut});
			FlxG.camera.followLerp = 1/120;
			camFollow.y = FlxG.height * 2;

			new FlxTimer().start(2.5, function(tmr:FlxTimer)
			{
				camFollow.x += 1200;

				donutShop.x += donutShop.width * 2.8;
				appleShopSign.x = donutShop.x - 120;

				dad.visible = true;
				boyfriend.visible = true;
				gf.visible = true;

				FlxG.camera.zoom = defaultCamZoom;
				camFollow.screenCenter();
				
				FlxG.sound.music.fadeOut(0.85, 0, (t:FlxTween) -> 
				{
					FlxG.sound.music.stop();
					FlxG.sound.music.volume = 1.0;
				});

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					seenCutscene = true;
					startCountdown();
				});
			});
		});
		*/

		if (seenCutscene)
			return; // startCountdown();

		inCutscene = true;
		camHUD.alpha = 0;

		dad.visible = false;
		boyfriend.visible = false;
		gf.visible = false;

		//FlxG.camera.zoom = defaultCamZoom * 1.2;

		FlxG.sound.playMusic(Paths.music('sneak'), 0);
		FlxG.sound.music.fadeIn(5, 0, 0.35);

		FlxG.camera.zoom = 1.4;

		camFollowPos.x = appleShopSign.getMidpoint().x;
		camFollowPos.y = appleShopSign.getMidpoint().y;

		new FlxTimer().start(5, (t:FlxTimer) -> 
		{
			dad.visible = true;
			boyfriend.visible = true;
			gf.visible = true;

			camFollowPos.x = dad.getGraphicMidpoint().x;
			camFollowPos.y = dad.getGraphicMidpoint().y;
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 1.5, {ease: FlxEase.quadInOut});
			//FlxG.camera.zoom = defaultCamZoom;
			FlxG.sound.music.fadeOut();
		});

		new FlxTimer().start(7, (t:FlxTimer) -> 
		{
			FlxTween.tween(camHUD, {alpha: 1}, 1);
			startCountdown();
		});
	}

	function playVideoCutscene(name:String):Void
	{
		if (name == "" || name == null || seenCutscene #if !USE_VIDEOS || true #end)
		{
			startCountdown();
			return;
		}

		// USE DONUT VIDEO !!!!!!!!! sack

		#if USE_VIDEOS
		trace("Hi im usnig vidoe");
		inCutscene = true;

		FlxG.switchState(new donut.VideoState(Paths.video(name), new PlayState()));

		#end
		seenCutscene = true;
	}

	var startTimer:FlxTimer;

	function startCountdown():Void
	{
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		if (curSong.toLowerCase() != "abundance")
			FlxTween.tween(camHUD, {alpha: 1}, (Conductor.crochet / 1000) * 2);
		if (curSong.toLowerCase() == "forgotten")
		{
			// cuz for some reason i jsut cant do it on the group and i dont wanna debug
			cpuStrums.forEach((s:StrumNote) -> 
			{
				s.visible = false;
				s.active = false;
			});
		}

		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5; 

		var swagCounter:Int = 0;
		startedCountdown = true;
		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image("ready"));
					ready.scrollFactor.set();
					ready.updateHitbox();
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
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image("set"));
					set.scrollFactor.set();
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
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image("go"));
					go.scrollFactor.set();
					go.updateHitbox();
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
			}
			swagCounter++;
		}, 5);

	}

	var previousFrameTime:Int = 0;
	var songTime:Float = 0;

	// DONT GIVE A SHIT ANYMORE
	// THIS INPUT CODE IS FROM PSYCH ENGINE I LOVE PSYCH ENGINE !!!!!!!
	private function getKeyFromEvent(key:FlxKey):Int
	{
		if (key != NONE)
		{
			for (i in 0...binds.length)
			{
				for (j in 0...binds[i].length)
				{
					if (key == binds[i][j])
						return i;
				}
			}
		}

		return -1;
	}

	private function releaseInput(evt:KeyboardEvent):Void // handles releases
	{
		var key:Int = getKeyFromEvent(evt.keyCode);

		if (!PlayStateChangeables.botPlay && startedCountdown && !paused && key > -1)
		{
			var strum:StrumNote = playerStrums.members[key];
			if (strum != null)
				strum.playAnim("static");
		}
	}

	private function handleInput(evt:KeyboardEvent):Void 
	{
		var key:Int = getKeyFromEvent(evt.keyCode);

		if (!PlayStateChangeables.botPlay && startedCountdown && !paused && key > -1 && FlxG.keys.checkStatus(evt.keyCode, JUST_PRESSED))
		{
			if (!boyfriend.stunned && generatedMusic && !endingSong)
			{
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !FlxG.save.data.ghost;

				var pressNotes:Array<Note> = [];
				var notesStopped:Bool = false;
				var sortedNotesList:Array<Note> = [];

				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote)
					{
						if (daNote.noteData == key)
							sortedNotesList.push(daNote);
						canMiss = true;
					}
				});

				sortedNotesList.sort((a:Note, b:Note) -> FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime));
			
				//trace(sortedNotesList);

				if (sortedNotesList.length > 0) 
				{
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes)
						{
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1)
							{
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							}
							else
								notesStopped = true;
						}

						if (!notesStopped)
						{
							noteHit(epicNote);
							pressNotes.push(epicNote);
						}
					}
				}
				else
				{
					if (canMiss)
						noteMiss(key);
				}

				Conductor.songPosition = lastTime;
			}

			var strum:StrumNote = playerStrums.members[key];
			if (strum != null && strum.animation.curAnim != null && strum.animation.curAnim.name != "confirm")
				strum.playAnim("pressed");
		}
	}

	var songStarted = false;
	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(curSong), 1, false);

		// Lols this sucks but it works
		FlxG.sound.music.onComplete = 
			if (canViewCutscene && !PlayStateChangeables.optimize)
			{
				switch (curSong.toLowerCase())
				{
					case "allergy":allergyEndCutscene;
					default:endSong;
				};
			}
			else
				endSong;

		dadVocals.play();
		bfVocals.play();

		songLength = FlxG.sound.music.length;
		if (FlxG.save.data.songPosition)
		{
			songTimeBar.setRange(0, songLength);

			songLengthText.text = FlxStringUtil.formatTime(songLength / 1000);
			songLengthText.x = FlxG.width - songLengthText.width - 5;
		}

		if (!PlayStateChangeables.optimize)
		{
			switch (curSong.toLowerCase())
			{
				case "halloween":
					inCutscene = true;

					dad.visible = false;

					syncedChar.visible = true;
					syncedChar.sound = FlxG.sound.music;
					syncedChar.soundLength = 11290;
					syncedChar.start("talk");
		
					camFollow.setPosition(syncedChar.getGraphicMidpoint().x + 125, syncedChar.getGraphicMidpoint().y);
					FlxTween.tween(FlxG.camera, {zoom: 1.25}, 1.35, {ease: FlxEase.expoInOut});
					FlxTween.tween(camHUD, {alpha: 0}, 0.2);
			}
		}

		#if (desktop && !hl)
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + " " + curSong + " (" + storyDifficultyText + ") " + Ratings.generateLetterRank(), "\nAcc: " + FlxMath.roundDecimal(accuracy, Ratings.accuracyPrecision) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
		#end
	}

	var debugNum:Int = 0;

	private function generateSong():Void
	{
		Conductor.bpm = SONG.bpm;

		if (SONG.needsVoices)
		{
			dadVocals = new FlxSound().loadEmbedded(Paths.voices(curSong));
			bfVocals = new FlxSound().loadEmbedded(Paths.voices(curSong, true));
		}
		else
		{
			dadVocals = new FlxSound();
			bfVocals = new FlxSound();
		}

		FlxG.sound.list.add(dadVocals);
		FlxG.sound.list.add(bfVocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		for (section in SONG.notes)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset;
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var gottaHitNote:Bool = (songNotes[1] > 3) ? !section.mustHitSection : section.mustHitSection;

				if (!gottaHitNote && PlayStateChangeables.optimize)
					continue;
				if (songNotes[3] == 2)
					continue;

				if (daStrumTime < 0)
					daStrumTime = 0;

				var oldNote:Note = (unspawnNotes.length > 0) ? unspawnNotes[Std.int(unspawnNotes.length - 1)] : null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, songNotes[3]);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set();
				swagNote.mustPress = gottaHitNote;
				if (swagNote.mustPress)
					swagNote.x += FlxG.width / 2; // general offset
				else
				{
					if (swagNote.noteData >= 2)
						swagNote.x += FlxG.width / 1.8;
				}

				unspawnNotes.push(swagNote);

				var susLength:Float = swagNote.sustainLength / Conductor.stepCrochet;
				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
						sustainNote.x += FlxG.width / 2; // general offset

					unspawnNotes.push(sustainNote);
				}
			}
		}

		unspawnNotes.sort((a:Note, b:Note) -> Std.int(a.strumTime - b.strumTime));
		generatedMusic = true;
	}

	var tweenStaticArrows:Bool = true;
	private function generateStaticArrows(player:Int):Void
	{
		if (player == 0 && PlayStateChangeables.optimize)
			return;

		for (i in 0...4)
		{
			var targetAlpha:Float = 1.0;
			if (PlayStateChangeables.middlescroll && player == 0) 
				targetAlpha = 0.35;

			var babyArrow:StrumNote = new StrumNote(0, strumLine.y, i, player);

			if (!isStoryMode && tweenStaticArrows)
			{
				babyArrow.angle = 15 * i;
				babyArrow.y -= 35;
				babyArrow.alpha = 0;

				FlxTween.tween(babyArrow, {y: babyArrow.y + 35, alpha: targetAlpha, angle: 0}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			(player == 0) ? cpuStrums.add(babyArrow) : playerStrums.add(babyArrow);
			
			if (PlayStateChangeables.optimize)
			{
				babyArrow.x -= 278;
			}
			else if (PlayStateChangeables.middlescroll)
			{
				switch (player)
				{
					case 0:
						if (i >= 2)
							babyArrow.x += FlxG.width / 1.8;
						
					case 1:
						babyArrow.x -= 278;
				}
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAdd();
		}
	}

	override function openSubState(SubState:FlxSubState):Void
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);

		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				dadVocals.pause();
				bfVocals.pause();
			}

			#if (desktop && !hl)
			DiscordClient.changePresence("PAUSED on " + curSong + " (" + storyDifficultyText + ") " + Ratings.generateLetterRank(), "Acc: " + FlxMath.roundDecimal(accuracy, Ratings.accuracyPrecision) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
			#end
			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState():Void
	{
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);

		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
				resyncVocals();

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if (desktop && !hl)
			if (startTimer.finished)
				DiscordClient.changePresence(detailsText + " " + curSong + " (" + storyDifficultyText + ") " + Ratings.generateLetterRank(), "\nAcc: " + FlxMath.roundDecimal(accuracy, Ratings.accuracyPrecision) + "% | Score: " + songScore + " | Misses: " + misses, iconRPC, true, songLength - Conductor.songPosition);
			else
				DiscordClient.changePresence(detailsText, curSong + " (" + storyDifficultyText + ") " + Ratings.generateLetterRank(), iconRPC);
			#end
		}

		super.closeSubState();
	}
	
	function resyncVocals():Void
	{
		dadVocals.pause();
		bfVocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		dadVocals.time = Conductor.songPosition;
		bfVocals.time = Conductor.songPosition;

		dadVocals.play();
		bfVocals.play();

		#if (desktop && !hl)
		DiscordClient.changePresence(detailsText + " " + curSong + " (" + storyDifficultyText + ") " + Ratings.generateLetterRank(), "\nAcc: " + FlxMath.roundDecimal(accuracy, Ratings.accuracyPrecision) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;

	var drainTimerShit:Float = 0;
	
	var singAnims:Array<String> = ["left", "down", "up", "right"];

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		var cameraLerp:Float = CoolUtil.boundTo(elapsed * 2.4, 0, 1);
		camFollow.x = FlxMath.lerp(camFollow.x, camFollowPos.x, cameraLerp);
		camFollow.y = FlxMath.lerp(camFollow.y, camFollowPos.y, cameraLerp);

		if (Main.debugMode)
		{
			if (FlxG.keys.justPressed.E && curSong.toLowerCase() == "allergy")
			{
				FlxG.sound.music.time = FlxG.sound.music.length - 5000;
				resyncVocals();
			}
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (PlayStateChangeables.botPlay && FlxG.keys.justPressed.T)
			camHUD.visible = !camHUD.visible;

		if (!PlayStateChangeables.optimize)
		{
			switch (curStage)
			{
				case "donutshop":

					switch (curSong.toLowerCase())
					{
						case "allergy":
							if (!micahWalkDone && micah.x >= 2000)
							{
								micahWalkDone = true;
								micah.velocity.x = 0;
								
								micah.kill();
								if (members.contains(micah))
									remove(micah);
								micah.destroy();
							}

							if (ocean.x >= (appleShopSign.x + 170) - 20) 
							{
								oceanInPos = true;
								ocean.velocity.x = 0;
								ocean.x = appleShopSign.x + 170;
								ocean.animation.play("dance");
								ocean.offset.set();
							}

						case "halloween":
							if (inCutscene)
							{
								//camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 15);
								syncedChar.sound = FlxG.sound.music;
								//syncedAtlasChar.updateSound(FlxG.sound.music);
							}
					}
			}
		}

		if (donutDrain) 
		{
			if (drainTimerShit <= drainTime)
			{
				if (health > 0.01)
					health -= elapsed / 8;//health -= donutDps;
			}
			else
			{
				donutDrain = false;
				drainTimerShit = 0;
			}

			if (health == 0)
				health = 0.001;

			drainTimerShit += elapsed;
		}

		if (PlayStateChangeables.botPlay)
		{
			botPlaySine += 180 * elapsed;
			botPlayTxt.alpha = 1 - Math.sin((Math.PI * botPlaySine) / 180);
		}

		if (FlxG.sound.music != null && FlxG.sound.music.playing && FlxG.save.data.songPosition)
			songTimeText.text = '${FlxStringUtil.formatTime(FlxG.sound.music.time / 1000)}';

		if (controls.PAUSE && startedCountdown && !inCutscene)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			openSubState(new PauseSubState());
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			#if (desktop && !hl)
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			MusicBeatState.switchState(new ChartingState());
		}

		// istg
		if (iconP1 != null && iconP2 != null)
		{
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 3, 0, 1);

			iconP1.setGraphicSize(Std.int(FlxMath.lerp(iconP1.width, 150, lerpVal)));
			iconP2.setGraphicSize(Std.int(FlxMath.lerp(iconP2.width, 150, lerpVal)));

			iconP1.updateHitbox();
			iconP2.updateHitbox();
			
			var iconOffset:Int = 26;

			iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
			iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

			if (health > 2)
				health = 2;

			if (iconP1.animation.curAnim != null && iconP2.animation.curAnim != null)
			{
				iconP1.animation.curAnim.curFrame = (healthBar.percent < 20) ? 1 : 0;
				iconP2.animation.curAnim.curFrame = (healthBar.percent > 80) ? 1 : 0;
			}
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;
			songPositionBar = Conductor.songPosition;

			//trace('${Conductor.songPosition} | ${FlxG.sound.music.time} | ${FlxG.sound.music.length}');

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong && !inCutscene)
		{
			var centerPoint:FlxPoint = gf.getGraphicMidpoint();
			var daSection:SwagSection = PlayState.SONG.notes[Std.int(curStep / 16)];

			if (camFollowPos.x != centerPoint.x && camFollowPos.y != centerPoint.y && daSection.isDuet)
				camFollowPos.set(centerPoint.x, centerPoint.y + 50);

			var charPos:Array<Float> = charCamPos[dad.character];
			if (charPos == null) // default
				charPos = [150, -100];

			if (camFollowPos.x != (dad.getMidpoint().x + charPos[0]) && !daSection.mustHitSection && !daSection.isDuet)
				camFollowPos.set(dad.getMidpoint().x + charPos[0], dad.getMidpoint().y + charPos[1]);
			if (daSection.mustHitSection && camFollowPos.x != boyfriend.getMidpoint().x - 100 && !daSection.isDuet)
				camFollowPos.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed*3.125), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed*3.125), 0, 1));
		}

		if (health <= 0 || (FlxG.save.data.resetButton && FlxG.keys.justPressed.R) && !PlayStateChangeables.botPlay) // Do not die if botplay
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			deaths++;

			bfVocals.stop();
			dadVocals.stop();
			FlxG.sound.music.stop();

			//trace(boyfriend.getScreenPosition(null, camGame).x);
			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if (desktop && !hl)
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("GAME OVER -- " + curSong + " (" + storyDifficultyText + ") " + Ratings.generateLetterRank(),"\nAcc: " + FlxMath.roundDecimal(accuracy, Ratings.accuracyPrecision) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
			#end
			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (unspawnNotes[0] != null)
		{
			var time:Float = 2000;
			if (scrollSpeed < 1)
				time /= scrollSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);

				unspawnNotes.splice(unspawnNotes.indexOf(dunceNote), 1);
			}
		}

		if (generatedMusic)
		{
			var holdArray:Array<Bool> = [controls.NOTE_LEFT, controls.NOTE_DOWN, controls.NOTE_UP, controls.NOTE_RIGHT];

			notes.forEachAlive(function(daNote:Note)
			{	
				daNote.visible = daNote.isOnScreen(camHUD);

				var strumGroup:FlxTypedGroup<StrumNote> = daNote.mustPress ? playerStrums : strumLineNotes;

				if (PlayStateChangeables.useDownscroll)
				{
					daNote.y = (strumGroup.members[daNote.noteData].y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(scrollSpeed, 2)) - daNote.offsetY;
					
					if (daNote.isSustainNote)
					{
						// Remember = minus makes notes go up, plus makes them go down
						daNote.y += (daNote.animation.curAnim.name.endsWith("end") && daNote.prevNote != null) ? daNote.prevNote.height : daNote.height / 2;

						// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
						if (!PlayStateChangeables.botPlay)
						{
							if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit || holdArray[Math.floor(Math.abs(daNote.noteData))] && !daNote.tooLate))
							{
								// Clip to strumline
								var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
								swagRect.height = (strumLineNotes.members[daNote.noteData].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						}
						else 
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
							swagRect.height = (strumLineNotes.members[daNote.noteData].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
				}
				else
				{
					daNote.y = (strumGroup.members[daNote.noteData].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(scrollSpeed, 2)) + daNote.offsetY;

					if (daNote.isSustainNote)
					{
						daNote.y -= daNote.height / 2;

						if (!PlayStateChangeables.botPlay)
						{
							if (!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit || holdArray[Math.floor(Math.abs(daNote.noteData))] && !daNote.tooLate)
							{
								// Clip to strumline
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (strumLineNotes.members[daNote.noteData].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
						else 
						{
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (strumLineNotes.members[daNote.noteData].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}
				}
	
				if (PlayStateChangeables.botPlay && daNote.mustPress && daNote.canBeHit && !daNote.wasGoodHit)
				{
					if (Conductor.songPosition >= daNote.strumTime)
						noteHit(daNote);
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (!camZooming)
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null && SONG.notes[Math.floor(curStep / 16)].altAnim)
						altAnim = "-alt";

					dad.playAnim("sing" + singAnims[Std.int(Math.abs(daNote.noteData))].toUpperCase() + altAnim, true);
					
					if (FlxG.save.data.cpuStrums)
					{
						var strum:StrumNote = cpuStrums.members[daNote.noteData];
						if (strum != null)
							strum.playAnim("confirm");
					}
					
					dad.holdTimer = 0;

					if (SONG.needsVoices)
						bfVocals.volume = 1;

					if (health > 0.1 && dadCanDamage)
						health -= 0.017;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				if (daNote.mustPress)
				{
					daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.angle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
					daNote.alpha = !daNote.isSustainNote ? playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha : 0.6;
				}
				else if (!daNote.wasGoodHit)
				{
					if (!PlayStateChangeables.middlescroll)
					{
						daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
						daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
						if (!daNote.isSustainNote)
							daNote.angle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
						daNote.alpha = !daNote.isSustainNote ? strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha : 0.6;
					}
					else
					{
						if (daNote.isSustainNote)
							daNote.x = strumLineNotes.members[Std.int(Math.floor(Math.abs(daNote.noteData)))].x + daNote.width;
						daNote.alpha = 0.35;
					}
				}
				
				if (daNote.isSustainNote && !PlayStateChangeables.middlescroll || daNote.isSustainNote && PlayStateChangeables.middlescroll && daNote.mustPress)
					daNote.x += daNote.width / 2 + 17;

				//trace(daNote.y);
				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));
				if ((daNote.mustPress && daNote.tooLate && !PlayStateChangeables.useDownscroll || daNote.mustPress 
					&& daNote.tooLate && PlayStateChangeables.useDownscroll) && daNote.mustPress)
				{
						if (daNote.isSustainNote && daNote.wasGoodHit)
						{
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
						else
						{
							if (daNote.noteType != 2)
								noteMiss(daNote.noteData, daNote);
						}
					}
				});
			}

		if (PlayStateChangeables.botPlay)
		{
			playerStrums.forEach(function(spr:StrumNote)
			{
				if (spr.animation.finished && spr.animation.curAnim != null && spr.animation.curAnim.name != "static")
					spr.playAnim("static");
			});
		}

		if (FlxG.save.data.cpuStrums)
		{
			cpuStrums.forEach(function(spr:StrumNote)
			{
				if (spr.animation.finished && spr.animation.curAnim != null && spr.animation.curAnim.name != "static")
					spr.playAnim("static");
			});
		}

		if (generatedMusic && !inCutscene)
		{
			if (!PlayStateChangeables.botPlay)
				keyShit();
			else if (boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * 0.0044 
				&& boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')
				&& !Boyfriend.specialAnims.contains(boyfriend.animation.curAnim.name)) 
				{
					boyfriend.dance();
				}
		}

	}

	function endSong():Void
	{
		endingSong = true;

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);

		if (isStoryMode)
			campaignMisses = misses;
		else
		{
			PlayStateChangeables.botPlay = false;
			PlayStateChangeables.useDownscroll = false;
		}

		FlxG.sound.music.volume = 0;
		FlxG.sound.music.pause();

		dadVocals.volume = 0;
		bfVocals.volume = 0;
		dadVocals.pause();
		bfVocals.pause();
		
		if (SONG.validScore)
		{
			// adjusting the highscore song name to be compatible
			// would read original scores if we didn't change packages
			var songHighscore = StringTools.replace(curSong, " ", "-");
			Highscore.saveScore(songHighscore, Math.round(songScore), storyDifficulty);
			Highscore.saveCombo(songHighscore, Ratings.generateLetterRank(), storyDifficulty);
		}

		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			offsetTesting = false;
			MusicBeatState.switchState(new OptionsMenu());
			FlxG.save.data.offset = offsetTest;
			FlxG.save.flush();
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				//case "allergy":
				//	allergyEndCutscene();
				
				case "dingdongdoom":
					if (misses == 0)
						Main.achv.trigger("dingdongdoomhard");
			}


			if (isStoryMode)
			{
				campaignScore += Math.round(songScore);
				storyPlaylist.shift();

				if (storyPlaylist.length <= 0)
				{
					paused = true;

					FlxG.sound.music.stop();
					bfVocals.stop();
					dadVocals.stop();

					MusicBeatState.switchState(new StoryMenuState());
					GameData.setUnlocked(storyWeek, true);

					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					if (SONG.validScore)
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);

					if (!PlayStateChangeables.botPlay)
						Main.achv.trigger('week$storyWeek');
				}
				else
				{
					if (curSong.toLowerCase() == "donut shop")
					{
						FlxTransitionableState.skipNextTransIn = true;
						FlxTransitionableState.skipNextTransOut = true;
					}

					// adjusting the song name to be compatible
					var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");
					var poop:String = Highscore.formatSong(songFormat, storyDifficulty);
					prevCamFollow = camFollowPos;

					var swag = Song.loadFromJson(poop, PlayState.storyPlaylist[0]);
					PlayState.SONG = swag;
					//trace(PlayState.SONG);
					FlxG.sound.music.stop();

					//LoadingState.loadAndSwitchState(new PlayState());
					LoadState.loadAndSwitchState(new PlayState());
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				paused = true;

				FlxG.sound.music.stop();
				bfVocals.stop();
				dadVocals.stop();

				var next:MusicBeatState = (curSong.toLowerCase() == "test") ? new MainMenuState() : new FreeplayState();
				MusicBeatState.switchState(next);
			}
		}
	}

	function allergyEndCutscene():Void
	{
		if (!canViewCutscene)
			return;

		camZooming = false;
		inCutscene = true;
		endingSong = true; // ugh

		FlxG.sound.music.volume = 0;
		FlxG.sound.music.pause();

		dadVocals.volume = 0;
		bfVocals.volume = 0;
		dadVocals.pause();
		bfVocals.pause();		

		FlxTween.tween(camHUD, {alpha: 0}, 1);

		var deadBro:CutsceneSprite = new CutsceneSprite(dad.x, dad.y);
		deadBro.frames = Paths.getSparrowAtlas("dingAllergyDies", "donutshop");
		deadBro.addAnim("yum", "dingd Allergy Nomnom", 24, false, [78, 98]);
		deadBro.addAnim("death", "dingd Allergy Death", 24, false, [-3, -5]);

		deadBro.addFrameEvent("yum", 26, () -> FlxG.sound.play(Paths.sound("nom", "donutshop")));
		deadBro.addFrameEvent("death", 13, () -> FlxG.sound.play(Paths.sound("fall", "donutshop")));

		deadBro.animation.finishCallback = (anim:String) ->
		{
			switch (anim)
			{
				case "yum":
					FlxTween.tween(FlxG.camera, {zoom: 0.95}, 0.35, {ease: FlxEase.quadInOut});
					deadBro.playAnim("death");

				case "death":
					new FlxTimer().start(2, (t:FlxTimer) -> {
						boyfriend.playAnim("singDOWNmiss", true);
						FlxTween.tween(FlxG.camera, {zoom: 1}, 0.35, {ease: FlxEase.quadInOut});
						camFollowPos.set(boyfriend.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);
					});

					new FlxTimer().start(4, (t:FlxTimer) -> {
						gameOverlaySprite.alpha = 1;
						endSong();
					});
			}
		}
		insert(members.indexOf(dad), deadBro);
		dad.visible = false;

		boyfriend.animation.finishCallback = (anim:String) -> 
		{
			if (anim == "singDOWNmiss")
				boyfriend.animation.play("singDOWNmiss", true, false, 4);
		}

		FlxTween.tween(FlxG.camera, {zoom: 1.1}, 0.7, {ease: FlxEase.quadInOut});
		camFollowPos.set(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		deadBro.playAnim("yum");
		deadBro.updateHitbox();
	}

	var endingSong:Bool = false;
	var hits:Array<Float> = [];
	var offsetTest:Float = 0;
	private function popUpScore(daNote:Note = null):Void
	{
		//var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
		//var wife:Float = EtternaFunctions.wife3(-noteDiff, Conductor.timeScale);
		// boyfriend.playAnim('hey');
		//bfVocals.volume = 1;
		//dadVocals.volume = 1;
		var placement:String = Std.string(combo);
		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.exists = false;
		//coolText.screenCenter();
		coolText.x = FlxG.width - 140;
		coolText.y = FlxG.height - 25;

		var score:Int = 350;
		var daRating:String = daNote.rating;

		if (daNote.noteType != 2)
		{
			switch (daRating)
			{
				case 'shit':
					score = 50;
					shits++;
				case 'bad':
					score = 100;
					bads++;
					hitNotes += 0.5;

				case 'good':
					score = 200;
					goods++;
					hitNotes += 0.75;
				case 'sick':
					hitNotes += 1;
					sicks++;
			}
		}

		songScore += score;

		var rating:FlxSprite = new FlxSprite().loadGraphic(Paths.image(daRating));
		rating.setPosition(coolText.x - 125, (FlxG.height - rating.height) - 24);
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		
		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image("combo"));
		comboSpr.setPosition(rating.x + 60, rating.y + 65);
		comboSpr.acceleration.y = FlxG.random.int(200, 300);
		comboSpr.velocity.y -= FlxG.random.int(140, 160);
		comboSpr.velocity.x += FlxG.random.int(1, 10);

		if (!PlayStateChangeables.botPlay)
		{ 	
			if (daRating == "sick")
			{
				var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
				var stat:FlxSprite = playerStrums.members[Math.floor(Math.abs(daNote.noteData))];

				splash.setupSplash(stat.x, stat.y, daNote.noteData);
				grpNoteSplashes.add(splash);
			}

			insert(members.indexOf(strumLineNotes), rating);
		}

		rating.setGraphicSize(Std.int(rating.width * (0.7 * ratingSizeMult)));
		comboSpr.setGraphicSize(Std.int(comboSpr.width * (0.7 * ratingSizeMult))); // 0.7

		comboSpr.updateHitbox();
		rating.updateHitbox();

		comboSpr.cameras = [camHUD];
		rating.cameras = [camHUD];

		if (combo >= 10 && !PlayStateChangeables.botPlay)
		{
			insert(members.indexOf(strumLineNotes), comboSpr);

			var seperatedScore:Array<Int> = [];
			if (combo >= 1000)
				seperatedScore.push(Math.floor(combo / 1000) % 10);
			seperatedScore.push(Math.floor(combo / 100) % 10);
			seperatedScore.push(Math.floor(combo / 10) % 10);
			seperatedScore.push(combo % 10);

			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('num' + Std.int(i)));
				numScore.x = rating.x + ((43 * ratingSizeMult) * daLoop) - 50;
				numScore.y = rating.y + 100;
				numScore.cameras = [camHUD];
				numScore.setGraphicSize(Std.int(numScore.width * (0.5 * ratingSizeMult))); // 0.5
				numScore.updateHitbox();
				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);
				insert(members.indexOf(strumLineNotes), numScore);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				});

				daLoop++;
			}
		}

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();
				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.002
		});
	}

	// THIS FUNCTION JUST FUCKS WIT HELD NOTES AND BOTPLAY/REPLAY (also gamepad shit)
	private function keyShit():Void // I've invested in emma stocks
	{
		// control arrays, order L D R U
		var holdArray:Array<Bool> = [controls.NOTE_LEFT, controls.NOTE_DOWN, controls.NOTE_UP, controls.NOTE_RIGHT];

		if (holdArray.contains(true) && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && holdArray[daNote.noteData] && daNote.canBeHit && daNote.mustPress
					&& !daNote.tooLate && !daNote.wasGoodHit)
					noteHit(daNote);
			});
		}

		if (boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * 0.0044 
			&& boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')
			&& !Boyfriend.specialAnims.contains(boyfriend.animation.curAnim.name)
			&& !holdArray.contains(true)) 
		{
			boyfriend.dance();
		}
	}

	function noteMiss(direction:Int = 1, ?note:Note):Void
	{
		if (note != null && note.noteType == 2 || PlayStateChangeables.botPlay)
			return;

		if (!boyfriend.stunned)
		{
			bfVocals.volume = 0;
			health -= 0.04;

			if (combo > 5)
				gf.playAnim('sad', true);

			combo = 0;
			misses++;

			songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			boyfriend.playAnim('sing${singAnims[direction].toUpperCase()}miss', true);

			if (note != null)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}

			updateAccuracy();
		}
	}

	function donutNoteHit(note:Note):Void
	{
		if (!boyfriend.stunned)
		{
			donutDrain = true;
			songScore -= 10;

			boyfriend.playAnim("hit", true, false, 2);
			if (FlxG.save.data.flashing)
				camHUD.flash(FlxColor.RED, 0.12);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	function updateAccuracy():Void
	{
		totalPlayedNotes++;
		accuracy = Math.max(0, hitNotes / totalPlayedNotes * 100);

		scoreTxt.text = Ratings.calculateRanking(songScore, accuracy);
		//scoreTxt.x = (originalX - (scoreTxt.textField.length * scoreTxt.frameHeight / 2)) + 335;
	}

	function noteHit(note:Note):Void
	{
		if (note != null)
		{
			if (note.noteType == 2)
			{
				donutNoteHit(note);
				return;
			}

			goodNoteHit(note);
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!camZooming)
			camZooming = true;

		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);
		note.rating = Ratings.calculateRating(noteDiff);

		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				combo++;
				popUpScore(note);
				if (combo > 9999) combo = 9999;
			}
			else
				hitNotes++;

			health += 0.023;

			boyfriend.playAnim('sing${singAnims[note.noteData].toUpperCase()}', true);
			boyfriend.holdTimer = 0;
			
			var strum:StrumNote = playerStrums.members[note.noteData];
			if (strum != null)
				strum.playAnim("confirm");

			note.wasGoodHit = true;
			bfVocals.volume = 1;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
			else
				note.wasGoodHit = true;

			updateAccuracy();
		}
	}
		
	var startedMoving:Bool = false;
	var triggeredOcean:Bool = false;
	var allergyShakey:Bool = false;
	var danced:Bool = false;

	override function stepHit():Void
	{
		super.stepHit();

		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(dadVocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
		{
			resyncVocals();
		}

		// yes this updates every step.
		// yes this is bad
		// but i'm doing it to update misses and accuracy
		#if (desktop && !hl)
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		//DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "Acc: " + CoolUtil.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC,true,  songLength - Conductor.songPosition);
		DiscordClient.changePresence(detailsText, curSong + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end

		if (!PlayStateChangeables.optimize)
		{
			switch (curSong.toLowerCase())
			{
				case "allergy":
					switch (curStep)
					{
						case 316:
							defaultCamZoom *= (1.1 / stageZoom);
							gf.playAnim("cheer", true);
							boyfriend.playAnim("hey", true);

						case 320:
							defaultCamZoom /= (1.1 / stageZoom);

						case 640, 758, 1408, 1526: // 576 swag begin 640 boom boom // x,y,x,y - y - 10
							gameZoomMult = 2;
						

						case 704, 1472:
							gameZoomMult = 1;

						case 1600:
							gameZoomMult = 1;
					}

					if (curStep >= oceanWalkStep && !triggeredOcean)
					{
						ocean.active = true;
						ocean.animation.play("walk");
						ocean.offset.y = -7;
						ocean.velocity.x = 95;
						triggeredOcean = true;
					}

				case 'abundance':
					switch (curStep) // Wow!!!! a switch INSIDDE OF A SWITCH, FUCK MY LIFE
					{
						case 50:
							FlxTween.tween(camHUD, {alpha: 1}, 1);

						case 60:
							subtitleText.text = "Nuts.";
							subtitleText.visible = true;
							new FlxTimer().start(1, (t:FlxTimer) -> 
							{
								subtitleText.visible = false;
							});

						case 1600:
							trace('do nuts');

						case 1625:
							inCutscene = true;

							boyfriend.visible = false;
							var woo:CutsceneSprite = new CutsceneSprite(boyfriend.x + 10, boyfriend.y, Paths.getSparrowAtlas("WOO", "void"));
							woo.addAnim("woo", "BF WOOO", 24, false);
							woo.playAnim("woo");
							add(woo);

						case 1648:
							camHUD.visible = false;
							gameOverlaySprite.alpha = 1;
							gameOverlaySprite.visible = true;
					}
				
				case 'halloween':
					switch (curStep)
					{
						case 128:
							inCutscene = false;
							FlxG.camera.focusOn(camFollow.getPosition());
							FlxTween.tween(camHUD, {alpha: 1}, 0.2);
							dad.visible = true;
							syncedChar.visible = false;
							remove(syncedChar);
							syncedChar.destroy();

						case 400:
							defaultCamZoom = 0.95;

						case 512 | 576:
							defaultCamZoom = 1.05;

						case 528 | 592:
							defaultCamZoom = 1.15;

						case 536 | 600:
							defaultCamZoom = 1.2;
						
						case 543 | 607:
							defaultCamZoom = 0.85;
					}

				case 'allergic reaction':
					switch (curStep)
					{
						case 736:
							if (dad.animationOffsets.exists('prettyGood')) // have to check for offsets first so that some dumbass doesnt crash the game on accident
							{
								// 769
								trace('PRETTY GOOD OFFSETS ARE REAL, PLAYING DA ANIM');
	
								subtitleText.text = "Donuts... I'm allergic to... nuts.";
								subtitleText.visible = true;

								defaultCamZoom = 1.25;
								dad.playAnim('prettyGood', true);
							}

						case 769:
							subtitleText.visible = false;
							defaultCamZoom = 0.9;

						case 832:
							defaultCamZoom = 1;

						case 864:
							defaultCamZoom = 1.15;

						case 896:
							defaultCamZoom = 0.9;
					}

				case "dingdongdoom":
					switch (curStep)
					{
						case 32, 144:
							hudZoomMult = 1.16;

						case 48, 160:
							hudZoomMult = 1.33;

						case 64, 176:
							hudZoomMult = 1.498;

						case 80, 192:
							hudZoomMult = 1.664;

						case 96, 208:
							hudZoomMult = 1.83;
						
						case 112, 224:
							hudZoomMult = 1.996;

						case 240, 244:
							FlxG.camera.zoom += 0.0015;
							camHUD.zoom += 0.035;

						case 248, 250:
							FlxG.camera.zoom += 0.02;
							camHUD.zoom += 0.08;

						case 252, 253, 254, 255:
							FlxG.camera.zoom += 0.095;
							camHUD.zoom += 0.2;

					}
			}
		}
	}
	
	var dtrNight:Bool = false;

	override function beatHit():Void
	{
		super.beatHit();

		if (useShaders)
		{
			if (hueShader != null && FlxG.save.data.useShaders)  // TODO: DYNAMICIZE?
			{
				if (curBeat % 2 == 0)
					hueShader.update(0.25);
			}
		}

		if (generatedMusic)
			notes.sort(FlxSort.byY, (PlayStateChangeables.useDownscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.bpm = SONG.notes[Math.floor(curStep / 16)].bpm;
				FlxG.log.add('CHANGED BPM!');
			}

			if (dad != null && dad.character != "gf" && !dad.animation.curAnim.name.startsWith("sing"))
				dad.dance();
		}

		//if (camZooming && FlxG.camera.zoom < 1.35) {}
		if (zoomOnBeat && curBeat % 4 == 0 && camZooming)
		{
			FlxG.camera.zoom += (0.015 * gameZoomMult);
			camHUD.zoom += (0.03 * hudZoomMult);
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));
		
		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (gf != null && curBeat % gfSpeed == 0)
		{
			if (gf.animation.curAnim != null)
			{
				if ((gf.animation.curAnim.name == "cheer" && gf.animation.curAnim.finished) || gf.animation.curAnim.name != "cheer" 
					|| (gf.animation.curAnim.name == "sad" && gf.animation.curAnim.finished))
					gf.dance();
			}
		}

		if (boyfriend != null && (!boyfriend.animation.curAnim.name.startsWith("sing") || Boyfriend.specialAnims.contains(boyfriend.animation.curAnim.name) 
			&& boyfriend.animation.curAnim.finished))
			boyfriend.dance();

		switch (curStage)
		{
			case 'donutshop':
				if (!PlayStateChangeables.optimize)
				{
					donutShop.dance();
					lapisfox.dance();
					appleShopSign.dance();
					if (curSong.toLowerCase() == 'allergy')
					{
						if (ocean != null && oceanInPos) {
							if (curBeat % 2 == 0)
								ocean.animation.play("dance", true);
						}
						
						if (curBeat >= micahStartBeat)
						{
							if (micah != null && !micahWalkDone)
							{
								micah.visible = true;
								if (micah.animation != null) // Bruh
									micah.animation.play("micah walk");
								
								micah.velocity.x = 130;
							}
						}
					}
				}

			case 'donutropolis':
				if (!PlayStateChangeables.optimize)
				{
					//if (curBeat < 224)
					//	dingBoppers.animation.play("day", true);
					dingBoppers.animation.play("day", true);

					if (curBeat == 224 && !dtrNight)
						coolStuff();

					if (curBeat > 224 && dtrNight)
					{
						coolSky.color = 0xFF000033;
						backbuildings.animation.play("night", true);
						frontBuildings.animation.play("night", true);
						grassFloor.animation.play("night", true);
						dingBoppers.animation.play("night", true);
					}
				}
		}
	}

	var faded:Bool = false;
	var oldStrumY:Float = PlayStateChangeables.useDownscroll ? FlxG.height - 165 : 50;

	function allergyFadeBG(fadeIn:Bool = true)
	{
		if (PlayStateChangeables.optimize)
			return;

		var pests:Array<FlxSprite> = [healthBar, healthBarBG, scoreTxt, iconP1, iconP2];

		if (fadeIn)
		{
			if (faded) return;

			defaultCamZoom *= (1.2 / stageZoom);

			var pI:Int = 0;
			for (pest in pests)
			{
				pest.active = false;
				
				var coolY:Float = PlayStateChangeables.useDownscroll ? FlxG.height - pest.y : FlxG.height + pest.y;
				FlxTween.tween(pest, {y: coolY, alpha: 0}, 0.25, {ease: FlxEase.quadInOut, startDelay:pI * 0.05});
				pI++;
			}

			FlxTween.tween(camGame, {y: 100, height: FlxG.height - 200}, 0.25, {ease: FlxEase.quadInOut});
			
			var strumOffset:Int = 60;
			strumLine.y += PlayStateChangeables.useDownscroll ? -strumOffset : strumOffset;

			for (strum in strumLineNotes)
			{
				var sussyY:Float = PlayStateChangeables.useDownscroll ? strum.y - strumOffset : strum.y + strumOffset;
				FlxTween.tween(strum, {y: sussyY}, 0.2, {ease: FlxEase.quadInOut});
			}

			toggleBGStuff(false, true, false);
			CoolUtil.setCamFilters([camGame], [new ShaderFilter(hueShader.shader)]);
			faded = true;
		}
		else
		{
			if (!faded) return;

			defaultCamZoom /= (1.2 / stageZoom);

			var pI:Int = 0;
			for (pest in pests)
			{
				pest.active = false;
				var coolY:Float = PlayStateChangeables.useDownscroll ? FlxG.height - pest.y : FlxG.height + pest.y;
				FlxTween.tween(pest, {y: coolY, alpha: 1}, 0.25, {ease: FlxEase.quadInOut, startDelay:pI * 0.05});
				pI++;
			}

			FlxTween.tween(camGame, {y: 0, height: FlxG.height}, 0.25, {ease: FlxEase.quadInOut});
			
			var strumOffset:Int = 60;
			strumLine.y += PlayStateChangeables.useDownscroll ? strumOffset : -strumOffset;

			for (strum in strumLineNotes)
			{
				var sussyY:Float = PlayStateChangeables.useDownscroll ? strum.y + strumOffset : strum.y - strumOffset;
				FlxTween.tween(strum, {y: sussyY}, 0.2, {ease: FlxEase.quadInOut});
			}

			toggleBGStuff(true, true, true);
			CoolUtil.setCamFilters([camGame], []);

			faded = false;
		}
	}

	function toggleBGStuff(toggle:Bool = false, fade:Bool = false, fadeIn:Bool = true, duration:Float = 0.1):Void
	{
		if (bgGroup != null)
		{
			for (asset in bgGroup)
			{
				if (asset != null)
				{
					if (fade)
						FlxTween.tween(asset, {alpha: fadeIn ? 1 : 0}, duration);
					else
						asset.exists = toggle;
				}
			}
		}
		
		if (bgFrontGroup != null)
		{
			for (asset in bgFrontGroup)
			{
				if (asset != null)
				{
					if (fade)
						FlxTween.tween(asset, {alpha: fadeIn ? 1 : 0}, duration);
					else
						asset.exists = toggle;
				}
			}
		}

		if (ocean != null)
			ocean.exists = toggle;
	}

	function coolStuff():Void
	{
		if (FlxG.save.data.flashing)
		{
			FlxG.camera.flash();
			dtrNight = true;
		}
	}

	function set_scrollSpeed(value:Float):Float 
	{
		var ratio:Float = value / scrollSpeed;

		if (notes != null)
		{
			for (note in notes)
				if (note != null)
					note.resizeSustain(ratio);
		}

		if (unspawnNotes != null)
		{
			for (note in unspawnNotes)
				if (note != null)
					note.resizeSustain(ratio);
		}

		scrollSpeed = value;
		return scrollSpeed;
	}
}