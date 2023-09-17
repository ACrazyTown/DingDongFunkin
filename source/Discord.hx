package;

import sys.thread.Thread;
import Sys.sleep;
#if cpp
import discord_rpc.DiscordRpc;
#end

using StringTools;

class DiscordClient
{
	public static final clientID:String = "875028233043722270";
	public static var isInitialized:Bool = false;

	public static var daemon:Thread = null;

	public static var disconnected:Bool = false;

	public function new()
	{
		#if cpp
		DiscordRpc.start({
			clientID: clientID,
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});

		while (true)
		{
			DiscordRpc.process();
			sleep(2);
		}

		DiscordRpc.shutdown();
		#else
		trace("Won't initialise Discord Client!");
		#end
	}
	
	#if cpp
	public static function shutdown():Void
	{
		DiscordRpc.shutdown();
		daemon = null;
	}
	
	static function onReady():Void
	{
		DiscordRpc.presence({
			details: "In the Menus",
			state: null,
			largeImageKey: 'icon',
			largeImageText: "Rapping against DingDongDirt"
		});
	}

	static function onError(_code:Int, _message:String):Void
	{
		trace('DiscordRPC Error! $_code : $_message');
		
		disconnected = true;
		shutdown();
	}

	static function onDisconnected(_code:Int, _message:String):Void
	{
		trace('DiscordRPC disconnected! $_code : $_message');
	}

	public static function initialize():Void
	{
		daemon = Thread.create(() ->
		{
			new DiscordClient();
		});

		isInitialized = true;
	}

	public static var menuStrings:Array<String> = [
		"Eating donuts in the %s",
		"Chilling in the %s",
	];

	public static function menuPresence(menu:String = "Menus"):Void
	{
		var pDetails:String = FlxG.random.getObject(menuStrings).replace("%s", menu);
		changePresence(pDetails, null);
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey : String, ?hasStartTimestamp : Bool, ?endTimestamp: Float):Void
	{
		var startTimestamp:Float = hasStartTimestamp ? Date.now().getTime() : 0;

		if (endTimestamp > 0)
			endTimestamp = startTimestamp + endTimestamp;

		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: 'icon',
			largeImageText: "Rapping against DingDongDirt",
			smallImageKey : smallImageKey,
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp : Std.int(startTimestamp / 1000),
            endTimestamp : Std.int(endTimestamp / 1000)
		});
	}
	#end
}
