package donut.load;

import flixel.FlxG;
import openfl.utils.Assets;
import sys.FileSystem;
import sys.thread.Thread;

using StringTools;

@:enum abstract LoadableAssetType(String)
{
    var IMAGE = "IMAGE";
    var SOUND = "SOUND";
    var MUSIC = "MUSIC";
    var INST = "INST";
    var VOICES = "VOICES";
    var VOICES_BF = "VOICES_BF"; // Shitty, but only way I can make this work without ripping everything apart for the 38th time
}

typedef QueuedAsset =
{
    key:String,
    library:String,
    type:LoadableAssetType,
    excludeFromDump:Bool
}

class LoadManager
{
    public static var loadedStages:Array<String> = [];
    public static var loadMap:Map<String, Array<String>> = [];

    public var curStage:String;

    public var loadQueue:Array<QueuedAsset> = [];
    public var loaded:Int = 0;
    public var toLoad:Int = 0;
    public var finished:Bool = false;

    public var onFinish:Void->Void;
    public var onLoadError:Void->Void;

    private var excludeKeys:Array<String> = ["donutArrows", "donutBF_Assets", "donutGF_Assets"];

    inline public static function isLoaded(stage:String):Bool
        return loadedStages.contains(stage);

    public function new(stage:String, onLoad:Void->Void, ?onLoadError:Void->Void):Void
    {
        curStage = stage;

        loadQueue = [];
        loaded = 0;
        toLoad = 0;
        
        onFinish = onLoad;
        this.onLoadError = onLoadError;
    }

    public function startQueue():Void 
    {
        toLoad = loadQueue.length;

        Thread.create(() -> 
        {
            while (loadQueue.length != 0 && loaded != toLoad)
            {
                for (asset in loadQueue)
                {
                    var path:String = path(asset.key, asset.library, asset.type);

                    if (Assets.exists(path))
                    {
                        try 
                        {
                            LoadedAssets.add(path, curStage, asset.type);
                            if (asset.excludeFromDump)
                                LoadedAssets.excludes.push(path);
                            loaded++;
                        }
                        catch (e)
                        {
                            FlxG.log.error("ERROR LOADING!!! " + e.message);
                            toLoad--;
                        }
                    }
                    else
                    {
                        FlxG.log.warn("ASSET not real: " + path);
                        toLoad--;
                        if (onLoadError != null)
                            onLoadError();
                    }

                    loadQueue.remove(asset);
                }
            }

            if (onFinish != null)
                onFinish();
            finished = true;
        });
    }

    public function addToQueue(asset:QueuedAsset):Void
    {
        var path:String = path(asset.key, asset.library, asset.type);

        if (!loadQueue.contains(asset) && !excludeKeys.contains(asset.key) 
            && !LoadedAssets.exists(path, asset.type)) // duplicates
            loadQueue.push(asset);
    }

    inline public function removeFromQueue(asset:QueuedAsset):Void
        loadQueue.remove(asset);

    private function path(key:String, library:String, type:LoadableAssetType):String
    {
        // safer than casting ???
        var assetType:FNFAsset = switch (type)
        {
            case IMAGE: IMAGE;
            case SOUND: SOUND;
            case MUSIC: MUSIC;
            case INST: INST;
            case VOICES, VOICES_BF: VOICES;
        }

        return Paths.assetPath(key, library, assetType, null, type == VOICES_BF);
    }
}
