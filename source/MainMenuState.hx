package;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxSubState;
import donut.load.LoadedAssets;
import donut.GameData;
import flixel.FlxState;
import donut.achievement.AchievementData;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.effects.FlxFlicker;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.FlxSprite;

#if (desktop && !hl)
import Discord.DiscordClient;
#end

class WarningSubstate extends MusicBeatSubstate
{
    var overlay:FlxSprite;
    var warningText:FlxText;

    var warningTime:Float = 10;

    var inWarning:Bool = true;

    public function new():Void
    {
        super();

        overlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        overlay.alpha = 0;
        add(overlay);

        warningText = new FlxText(0, 0, FlxG.width, "error", 28);
        warningText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        warningText.alpha = 0;
        warningText.screenCenter();
        add(warningText);

        FlxTween.tween(overlay, {alpha: 0.7}, 0.5);
        FlxTween.tween(warningText, {alpha: 1}, 0.5);

        inWarning = true;
    }

    override function update(elapsed:Float):Void
    {
        if (inWarning)
        {
            warningTime -= elapsed;
            warningText.text = 'Make sure you\'ve setup your settings & keybinds!\nPress ESC or BKSP to cancel!\n\nProceeding in ${Math.round(warningTime)}s (or press ENTER)';

            if (warningTime <= 0)
                exit(true);
            else
            {
                if (controls.ACCEPT)
                    exit(true);
                if (controls.BACK)
                    exit(false);
            }
        }

        super.update(elapsed);
    }

    function exit(proceed:Bool):Void
    {
        inWarning = false;

        FlxTween.tween(overlay, {alpha: 0}, 0.5);
        FlxTween.tween(warningText, {alpha: 0}, 0.5, {onComplete: (t:FlxTween) -> 
        {
            var state:MainMenuState = cast FlxG.state;
            if (!proceed)
            {
                FlxG.sound.play(Paths.sound("cancelMenu"));

                for (item in state.optionGroup)
                {
                    if (item.ID != state.curSelected)
                    {
                        FlxTween.tween(item, {alpha: 1}, 1);
                        continue;
                    }

                    item.alpha = 0;
                    item.visible = true;
                    item.active = true;
                    item.exists = true;

                    FlxTween.tween(item, {alpha: 1}, 1);
                }
            }
            else
                MusicBeatState.switchState(Type.createInstance(state.nextState, []));

            close();
            MainMenuState.instance.canInput = true;
        }});
    }
}

class MainMenuState extends MusicBeatState
{
    public var curSelected:Int = 0;
    static var selected:Int; // this mentally pains me for some reason

    var menuItems:Array<String> = ["Freeplay", "Options", "Credits"];
    //var menuGroup:FlxTypedGroup<FlxSprite>;
    
    public static var mainColor:FlxColor = 0xFF53D6D8;
    public static var mainColorDark:FlxColor = 0xFF0E1330;
    public static var subtractColor:FlxColor = 0xFF23C1FF;

    var background:FlxSprite;
    var daText:String = "ermm.... THIS IS AN ERROR!!!";
    var scrollText:FlxText;

    public var optionGroup:FlxTypedGroup<FlxSprite>;

    public static var dingVer:String = "2.0";
    public static var donutVer:String = "1.0";
    public static var fnfVer:String = "0.2.8";

    var konami:Array<String> = ["UP", "UP", "DOWN", "DOWN", "LEFT", "RIGHT", "LEFT", "RIGHT", "B", "A"];
    var inputBuffer:Int = 0;

    public var nextState:Class<FlxState>;
    public static var instance:MainMenuState;

    var story:FlxSprite;

    override function create():Void
    {
        super.create();

        instance = this;

        #if (desktop && !hl)
		DiscordClient.changePresence("In the Menu", null);
		#end

        LoadedAssets.dumpAssets(false);

        persistentUpdate = persistentDraw = true;

        daText = FlxG.random.getObject(GameData.scrollTexts);

        background = new FlxSprite(0, 0, Paths.image("menu/freeplayBGDesat"));
        background.active = false;
        add(background);

        /* CREATE MAIN MENU */
        var tex:FlxAtlasFrames = Paths.getSparrowAtlas("menu/mainmenu_UI");

        optionGroup = new FlxTypedGroup<FlxSprite>();
        add(optionGroup);

        story = new FlxSprite(220);
        story.frames = tex;
        story.animation.addByPrefix("idle", "STORY MODE idle", 24);
        story.animation.addByPrefix("select", "STORY MODE selected", 24);
        story.animation.play("idle");
        story.animation.pause();
        story.color = FlxColor.GRAY;
        //story.scale.set(0.6666666666666667, 0.6666666666666667); // Bruh
        story.setGraphicSize(Std.int(story.width / 1.5));
        story.updateHitbox();
        story.screenCenter(Y);
        story.ID = 0;
        add(story);

        var oops = new FlxText(story.x + 50, story.y + 250, 0, "unavailable, sorry!", 32);
        add(oops);

        var i:Int = 0;
        for (optName in ["FREEPLAY", "OPTIONS", "CREDITS"]) 
        {
            var opt:FlxSprite = new FlxSprite();
            opt.frames = tex;
            opt.animation.addByPrefix("idle", optName, 24);
            opt.ID = i;
            opt.animation.play("idle");
            opt.setGraphicSize(Std.int(opt.width / 1.5));
            opt.updateHitbox();
            opt.setPosition(story.x + opt.width + 15, story.y + (i * 180));
            optionGroup.add(opt);

            i++;
        }

        scrollText = new FlxText(0, 10, 0, daText, 24);
        scrollText.x = -scrollText.width;
        scrollText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(scrollText);

        #if debug
        dingVer += " [DEBUG - " + KadeEngineData.commitHash + "]";
        #end

        var versionShit:FlxText = new FlxText(5, 0, 360, 'DING MOD v$dingVer\nENGINE v$donutVer (KE 1.5.4)\nFUNKIN\' v$fnfVer', 16);
        versionShit.wordWrap = false;
        versionShit.y = (FlxG.height - versionShit.height) + 5;
		//versionShit.setPosition((FlxG.width - versionShit.width) + 5, (FlxG.height - versionShit.height) + 15);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 18, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

        curSelected = selected;
        changeOption();

        #if !FREEPLAY
        if (FlxG.sound.music == null || !FlxG.sound.music.playing)
        {
            FlxG.sound.playMusic(Paths.music('freakyMenu'));
        }
        #end
    }

    public var canInput:Bool = true;
    override function update(elapsed:Float)
    {
        if (canInput)
        {
            // KONAMI
            if (FlxG.keys.firstJustPressed() != FlxKey.NONE && !AchievementData.isUnlocked("konami"))
            {
                var key:FlxKey = FlxG.keys.firstJustPressed();
                var keyName:String = Std.string(key);

                if (keyName == konami[0])
                {
                    inputBuffer++;
                    konami.shift();
                }
                else
                {
                    inputBuffer = 0;
                    konami = ["UP", "UP", "DOWN", "DOWN", "LEFT", "RIGHT", "LEFT", "RIGHT", "B", "A"];
                }

                if (inputBuffer == 10 && !GlobalTracker.localAchievements.get("konami")) // Hardcoded length of the KONAMI array
                    Main.achv.trigger("konami");
            }

            if (controls.ACCEPT)
                onEnter();
            if (controls.UI_UP_P)
                changeOption(-1);
            if (controls.UI_DOWN_P)
                changeOption(1);
            if (controls.BACK)
            {
                FlxG.sound.play(Paths.sound('cancelMenu'));

                MusicBeatState.switchState(new TitleState());
            }
        }

        scrollText.x += CoolUtil.boundTo(elapsed * 12, 0, 1) * 6;

        if (scrollText.x > FlxG.width + scrollText.width)
            scrollText.x = -scrollText.width;

        super.update(elapsed);
    }

    function onEnter():Void
    {
        if (curSelected == 2) {
            CoolUtil.website("https://github.com/ACrazyTown/DingDongFunkin#credits");
            return;
        }

        canInput = false;
        selected = curSelected;

        FlxG.sound.play(Paths.sound('confirmMenu'));

        nextState = switch (curSelected)
        {
            case 0: FreeplayState;
            case 1: OptionsMenu;
            case 4: StoryMenuState;
            case 5: AchievementState;
            default: StoryMenuState;
        }

        trace(nextState);
        
        for (item in optionGroup)
        {
            if (item.ID != curSelected)
            {
                trace(item.y);
                FlxTween.tween(item, {alpha: 0}, 1);
                continue;
            }

            FlxFlicker.flicker(item, 1.5, 0.08, false, false, (f:FlxFlicker) ->
            {
                if (GlobalTracker.isFirstTime && (menuItems[curSelected].toLowerCase() == "story mode" 
                    || menuItems[curSelected].toLowerCase() == "freeplay"))
                    openSubState(new WarningSubstate());
                else
                    MusicBeatState.switchState(cast Type.createInstance(nextState, []));
            });
        }
    }

    function changeOption(change:Int = 0):Void
    {
        if (change != 0) // dont play scroll when creating
            FlxG.sound.play(Paths.sound('scrollMenu'));

        trace("CHANGEING BRUH :Skl" + change);

        curSelected += change;

        if (curSelected >= menuItems.length)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = menuItems.length - 1;

        var tracker:Int = 0;
        
        //story.animation.play(curSelected == 0 ? "select" : "idle");

        optionGroup.forEach((item:FlxSprite) -> 
        {
            if (item.ID == curSelected) {
                item.x = story.x + item.width + 45;
                item.alpha = 1;
            } else {
                item.x = story.x + item.width + 15;
                item.alpha = 0.7;
            }
        });

        /*
        optionGroup.forEach((item:FlxSprite) -> 
        {
            item.targetX = tracker - curSelected;
            tracker++;

            var centered:Float = (FlxG.height - item.height) / 2;
            item.targetY = (item.ID != curSelected) ? centered + 60 : centered;
        });
        */
    }

    override function openSubState(SubState:FlxSubState):Void
    {
        persistentUpdate = false;
        super.openSubState(SubState);
    }

    override function closeSubState():Void
    {
        persistentUpdate = true;
        super.closeSubState();
    }
}
