package donut.load;

import flixel.util.typeLimit.OneOfTwo;
import haxe.io.Path;
import openfl.Assets;
import lime.utils.Assets as LimeAssets;
import openfl.media.Sound;
import donut.load.LoadManager.LoadableAssetType;
import openfl.system.System;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;

using StringTools;

class AssetCache<T> {

    public var cache:Map<String, T>;

    public function new()
    {
        cache = new Map<String, T>();
    }

    public function add(path:String, type:LoadableAssetType):Void
    {
        if (exists(path))
            return;
        
        switch (type)
        {
            case IMAGE:
                var graphic:FlxGraphic = FlxGraphic.fromAssetKey(path);
                graphic.persist = true;
                cache.set(path, cast graphic);
            
            case SOUND, MUSIC, INST, VOICES, VOICES_BF:
                if (Assets.exists(path))
                {
                    var sound:Sound = Assets.getSound(path, true);
                    cache.set(path, cast sound);
                }
        }
    }

    inline public function get(key:String):Null<T>
        return cache.get(key);

    public function remove(key:String):Void
    {
        var asset:T = get(key);
        if (asset is FlxGraphic) 
        {
            var graphic:FlxGraphic = cast asset;
            FlxG.bitmap.removeByKey(key);
            Assets.cache.removeBitmapData(key);
            graphic.destroy();
        }
        else if (asset is Sound)
            Assets.cache.removeSound(key);

        cache.remove(key);
    }

    inline public function exists(key:String):Bool
        return cache.exists(key);

    public function dump(?ignoreExcludes:Bool = true):Void
    {
        for (key in cache.keys())
        {
            if (!ignoreExcludes && (LoadedAssets.excludes.contains(key) || LoadedAssets.neverDump.contains(key)))
                continue;
            
            var asset:T = get(key);

            if (asset is FlxGraphic) 
            {
                var graphic:FlxGraphic = cast asset;
                FlxG.bitmap.removeByKey(key);
                graphic.destroy();
            }
            else if (asset is Sound)
                Assets.cache.removeSound(key);

            asset = null;
            remove(key);
        }
    }
}

class LoadedAssets
{
    public static var soundCache:AssetCache<Sound> = new AssetCache<Sound>();
    public static var musicCache:AssetCache<Sound> = new AssetCache<Sound>();
    // public static var songCache:AssetCache<SongCacheData> = new AssetCache<SongCacheData>();
    public static var graphicCache:AssetCache<FlxGraphic> = new AssetCache<FlxGraphic>();

    public static var atlasParentCache:Array<FlxGraphic> = [];

    public static var excludes:Array<String> = [];
    public static var neverDump:Array<String> = ["alphabet", "freakyMenu"];

    public static function add(path:String, libraryStage:String, type:LoadableAssetType):Void
    {
        getCache(type).add(path, type);
        
        if (GameData.stages.contains(libraryStage)) // negative values, not actual weeks, used for shared/preload etc.
        {
            if (LoadManager.loadMap.get(libraryStage) == null) // thats odd!!!
                LoadManager.loadMap.set(libraryStage, []);

            LoadManager.loadMap.get(libraryStage).push(path);
        }
    }

    inline public static function exists(path:String, type:LoadableAssetType):Bool
        return getCache(type).exists(path);

    inline public static function get(path:String, type:LoadableAssetType):OneOfTwo<Sound, FlxGraphic>
        return getCache(type).get(path);

    inline public static function remove(path:String, type:LoadableAssetType):Void
        return getCache(type).remove(path);

    public static function dumpLoaded(excludes:Array<String>):Void
    {
        for (stageKey in LoadManager.loadMap.keys())
        {
            var assetList:Array<String> = LoadManager.loadMap.get(stageKey);
            for (assetPath in assetList)
            {
                if (excludes.contains(assetPath) || neverDump.contains(assetPath))
                    continue;

                // SCUFFED CODE BRUH !!! SKULL
                var ext:String = Path.extension(assetPath).toLowerCase();
                var type:LoadableAssetType = IMAGE;
                if (ext == "png" || ext == "jpeg" || ext == "jpg")
                    type = IMAGE;
                else if (ext == "ogg" || ext == "mp3" || ext == "wav")
                {
                    if (assetPath.contains("/sounds/") || assetPath.contains("\\sounds\\"))
                        type = SOUND;
                      else if (assetPath.contains("/music/") || assetPath.contains("\\music\\"))
                        type = MUSIC;
                }

                getCache(type).remove(assetPath);
            }

            LoadManager.loadMap.remove(stageKey);
            LoadManager.loadedStages.remove(stageKey);
        }

        System.gc();
    }

    public static function dumpAssets(?ignoreExcludes:Bool = true):Void
    {
        graphicCache.dump();
        soundCache.dump();
        musicCache.dump();

        clearAtlasParents();

        LoadManager.loadMap.clear();
        LoadManager.loadedStages = [];

        System.gc();
    }

    public static function clearAtlasParents():Void
    {
        for (parent in atlasParentCache)
        {
            if (parent != null)
            {
                parent.persist = false;
                parent.destroyOnNoUse = true;
                parent.destroy();
            }
        }
    }

    inline private static function getCache(type:LoadableAssetType):AssetCache<Dynamic>
    {
        return switch (type)
        {
            case IMAGE: graphicCache;
            case SOUND: soundCache;
            case MUSIC, INST, VOICES, VOICES_BF: musicCache;
        }
    }
}
