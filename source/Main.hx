package;

#if CRASH_HANDLER
import openfl.system.Capabilities;
import donut.macro.MacroUtil;
import haxe.io.Path;
import sys.io.File;
import lime.app.Application;
import Discord.DiscordClient;
import haxe.CallStack;
import haxe.CallStack.StackItem;
import sys.FileSystem;
import openfl.events.UncaughtErrorEvent;
#end
import donut.achievement.AchievementManager;
import donut.display.FPSRAM;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;

using StringTools;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; //InitState // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 120; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	
	public var game:FlxGame = null;
	var fpsCounter:FPSRAM = null;

	public static var instance:Main;
	public static var achv:AchievementManager;
	public static var debugMode:Bool = #if (debug || FREEPLAY_UNLOCK) true #else false #end;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		instance = this;
		super();
		if (stage != null)
			init();
		else
			addEventListener(Event.ADDED_TO_STAGE, init);
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if web
		initialState = NoWeb;
		#end

		game = new FlxGame(gameWidth, gameHeight, initialState, #if (flixel < "5.0.0") zoom, #end framerate, framerate, skipSplash, startFullscreen);
		//FlxCamera.defaultZoom = zoom;
		addChild(game);

		FlxG.console.registerClass(GlobalTracker);
		
		//var shit:AchievementSprite = new AchievementSprite();
		//trace(shit.x);
		//trace(shit.y);
		//addChild(shit);

		achv = new AchievementManager();
		addChild(achv);

		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end

		#if !mobile 
		fpsCounter = new FPSRAM(0,0, 0xFFFFFF);
		addChild(fpsCounter);

		toggleFPS(FlxG.save.data.fps);
		#end
	}

	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + "DingCrashedBruh_" + dateNow + ".txt";

		@:privateAccess
		errMsg = 'Game Version: DING ${MainMenuState.dingVer} | DONUT Engine ${MainMenuState.donutVer} (${KadeEngineData.commitHash})\nHaxeFlixel Version: ${Std.string(FlxG.VERSION)}\nOS: ${Capabilities.os}\nGL Renderer: ${Std.string(Lib.current.stage.context3D.gl.getParameter(Lib.current.stage.context3D.gl.RENDERER))}\nGL Version: ${Std.string(Lib.current.stage.context3D.gl.getParameter(Lib.current.stage.context3D.gl.SHADING_LANGUAGE_VERSION))}\n-------------------------------------\n';

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error + "\n\nSEND THIS TO THE DISCORD PLS\n\n";

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved at: " + Path.normalize(path));

		Application.current.window.alert(errMsg, "DingFunkin Crash");
		DiscordClient.shutdown();
		Sys.exit(1);
	}
	#end

	inline public static function toggleFPS(fpsEnabled:Bool):Bool
	{
		return Main.instance.fpsCounter.visible = fpsEnabled;
	}

	public static function setFPSCap(cap:Int):Void
	{
		FlxG.updateFramerate = cap;
		FlxG.drawFramerate = cap;
	}

	inline public static function getFPSCap():Float
	{
		return Lib.current.stage.frameRate;
	}

	inline public static function getFPS():Float
	{
		return Main.instance.fpsCounter.currentFPS;
	}
}
