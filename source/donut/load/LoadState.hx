package donut.load;

import Note.NoteSkin;
import PlayState.PlayStateChangeables;
import sys.FileSystem;
import flixel.util.FlxColor;
import flixel.ui.FlxBar;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

using StringTools;

class LoadState extends MusicBeatState
{
    static var nextState:FlxState = null;

    var manager:LoadManager;
    var stageToLoad:String = "donutshop";

    var loadingImage:FlxSprite;
    var loadingBar:FlxBar = null;

    var haveMusic:Bool = true;

    public function new(stage:String, haveMusic:Bool = true)
    {
        stageToLoad = stage;
        this.haveMusic = haveMusic;

        super();
    }

    var funnyEasterEgg:Bool = false;
    override function create():Void
    {
        manager = new LoadManager(stageToLoad, onLoadFinish, onLoadError);

        PlayStateChangeables.update();
        //if (PlayStateChangeables.optimize)
        //   MusicBeatState.switchState(nextState);
        
        funnyEasterEgg = FlxG.random.bool(5);
        var daLoadingScreen:Int = FlxG.random.int(0, 3);

        loadingImage = new FlxSprite().loadGraphic(Paths.image(funnyEasterEgg ? "dings_words_of_encouragement" : 'loadingImage$daLoadingScreen'));
        loadingImage.screenCenter(); // for good measure
        add(loadingImage);

        trace('Loading week$stageToLoad with ATL${manager.toLoad} and loaded${manager.loaded}');

        // We're loading a new stage on Freeplay, let's clear MEM bruh
        if (!LoadManager.isLoaded(PlayState.SONG.stage.toLowerCase()))
            LoadedAssets.dumpLoaded([PlayState.SONG.stage.toLowerCase()]);

        // Preload stage + characters only if NOT optimized!!!
        if (!PlayStateChangeables.optimize || stageToLoad != "stage")
        {
            if (FileSystem.exists(FileSystem.absolutePath('assets/$stageToLoad')))
            {
                var abs:String = FileSystem.absolutePath('assets/$stageToLoad/images');
                if (FileSystem.exists(abs)) 
                {
                    for (file in FileSystem.readDirectory(abs))
                    {
                        if (!file.endsWith(".png"))
                            continue;
        
                        manager.addToQueue({
                            key: file.replace(".png", ""),
                            library: stageToLoad,
                            type: IMAGE,
                            excludeFromDump: false
                        });
                    }
                }
    
            }
           
            // CHARACTER FILES
            manager.addToQueue({
                key: 'characters/${PlayState.SONG.player1}/${PlayState.SONG.player1}',
                library: "shared",
                type: IMAGE,
                excludeFromDump: false
            });

            if (GameData.characters.contains(PlayState.SONG.player1 + "-dead"))
            {
                manager.addToQueue({
                    key: 'characters/${PlayState.SONG.player1}-dead/${PlayState.SONG.player1}-dead',
                    library: "shared",
                    type: IMAGE,
                    excludeFromDump: false
                }); 
            }

            manager.addToQueue({
                key: 'characters/${PlayState.SONG.player2}/${PlayState.SONG.player2}',
                library: "shared",
                type: IMAGE,
                excludeFromDump: false
            });

            manager.addToQueue({
                key: 'characters/${PlayState.SONG.gfVersion}/${PlayState.SONG.gfVersion}',
                library: "shared",
                type: IMAGE,
                excludeFromDump: false
            });
        }

        for (i in 0...10)
        {
            manager.addToQueue({
                key: 'num$i',
                library: "preload",
                type: IMAGE,
                excludeFromDump: true
            });
        }

        for (rating in Ratings.ratings)
        {
            manager.addToQueue({
                key: rating,
                library: "shared",
                type: IMAGE,
                excludeFromDump: true
            });
        }

        manager.addToQueue({
            key: NoteSkin.pathFromId(NoteSkin.DING),
            library: "shared",
            type: IMAGE,
            excludeFromDump: true
        });

        // Cache any additional noteskins
        if (PlayState.SONG != null)
        {
            var skins:Array<String> = GameData.songNoteSkins.get(PlayState.SONG.song.toLowerCase());
            if (skins != null)
            {
                for (skin in skins)
                {
                    manager.addToQueue({
                        key: NoteSkin.pathFromId(skin),
                        library: "shared",
                        type: IMAGE,
                        excludeFromDump: false
                    });
                }
            }
        }

        manager.addToQueue({
            key: "DING_notesplash",
            library: "shared",
            type: IMAGE,
            excludeFromDump: true
        });

        var musics:Array<String> = [
            "breakfast",
            "gameOver",
            "gameOverEnd"
        ];

        var sounds:Array<String> = [
            "missnote1",
            "missnote2",
            "missnote3",
            "intro3",
            "intro2",
            "intro1",
            "introGo"
        ];

        manager.addToQueue({
            key: PlayState.SONG.song,
            library: "songs",
            type: INST,
            excludeFromDump: false
        });

        manager.addToQueue({
            key: PlayState.SONG.song,
            library: "songs",
            type: VOICES,
            excludeFromDump: false
        });

        manager.addToQueue({
            key: PlayState.SONG.song,
            library: "songs",
            type: VOICES_BF,
            excludeFromDump: false
        });

        for (music in musics)
        {
            manager.addToQueue({
                key: music,
                library: null,
                type: MUSIC,
                excludeFromDump: true
            });
        }

        for (sound in sounds)
        {
            manager.addToQueue({
                key: sound,
                library: null,
                type: SOUND,
                excludeFromDump: true
            });
        }

        manager.startQueue();

        var loadingBarColor:FlxColor = 
        switch (daLoadingScreen)
        {
            case 0: 0xFF75EBED;
            case 1: 0xFF3763E9;
            case 2: 0xFFACFFBA;
            case 3: FlxColor.BLACK;
            default: FlxColor.BLACK;
        }

        if (funnyEasterEgg)
            loadingBarColor = FlxColor.BLACK;

        loadingBar = new FlxBar(20, (FlxG.height - 50), FlxBarFillDirection.HORIZONTAL_INSIDE_OUT, (FlxG.width - 40), 10, manager, "loaded", 0, manager.toLoad);
        loadingBar.createFilledBar(FlxColor.TRANSPARENT, loadingBarColor);
        add(loadingBar);

        super.create();
    }

    private function onLoadError():Void
    {
        if (loadingBar != null)
            loadingBar.setRange(0, manager.toLoad);
    }

    private function onLoadFinish():Void
    {
        LoadManager.loadedStages.push(stageToLoad);
        MusicBeatState.switchState(nextState);
    }

    inline public static function loadAndSwitchState(target:FlxState, ?stage:String):Void 
    {
        MusicBeatState.switchState(getState(target, stage));
    }

    public static function getState(target:FlxState, ?stage:String):FlxState
    {
        var _stage:String = stage;
        if (_stage == null || _stage == "")
            _stage = Song.getStage(PlayState.SONG.song);

        Paths.currentLevel = "shared";
        var state:FlxState = null;

        if (target == null)
            return null;

        nextState = target;
        state = !LoadManager.isLoaded(_stage) ? new LoadState(_stage) : target;

        return state;
    }
}
