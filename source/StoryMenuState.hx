package;

import donut.load.LoadState;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import openfl.Assets;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import donut.GameData;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;

class DiffArrow extends FlxSprite
{
    public var left:Bool = false;

    public function new(x:Float = 0, y:Float = 0, tex:FlxAtlasFrames, left:Bool)
    {
        super(x, y);

        frames = tex;
        this.left = left;

        setupAnims();
    }

    function setupAnims():Void
    {
        var dir:String = left ? "left" : "right";

        animation.addByPrefix("idle", 'arrow $dir', 24, false);
        animation.addByPrefix("press", 'arrow push $dir', 24, false);
        animation.play("idle");
        updateHitbox();
    }
}

class WeekSprite extends FlxSprite
{
    public var week:Int = 0;

    public function new(x:Float = 0, y:Float = 0, week:Int)
    {
        super(x, y);
        this.week = week;

        var daWeek:String = 'storymenu/week$week${GameData.unlockedWeeks[week] ? "" : "-locked"}';
        if (!Assets.exists(Paths.assetPath(daWeek, null, IMAGE)))
            daWeek = "storymenu/week-locked";
        loadGraphic(Paths.image(daWeek));
    }

    override function update(elapsed:Float):Void
    {
        /// truePos = FlxMath.lerp(truePos, 200 * -Math.abs(targetY), CoolUtil.boundTo(elapsed * 10, 0, 1));
        //alpha = FlxMath.lerp(alpha, nextAlpha, CoolUtil.boundTo(elapsed * 7, 0, 1));
        ///y = spacing + truePos;

        super.update(elapsed);
    }
}

class StoryMenuState extends MusicBeatState
{
    var curWeek(default, set):Int = 0;
    var curDiff(default, set):Int = 0;

    var storyBg:StoryBG;

    var diffArrowL:DiffArrow;
    var diffSprite:FlxSprite;
    var diffArrowR:DiffArrow;

    var weekSprites:FlxTypedGroup<WeekSprite>;
    var weekSprite:FlxSprite;

    var scoreTxt:FlxText;
    var tracksTxt:FlxText;

    var weekScore:Int = 0;
    var displayScore:Int = 0;

    override function create():Void
    {
        storyBg = new StoryBG();
        add(storyBg);

        var overlay:FlxSprite = new FlxSprite().loadGraphic(Paths.image("storymenu/fg"));
        overlay.x = FlxG.width - overlay.width;
        add(overlay);

        var uiFrames:flixel.graphics.frames.FlxAtlasFrames = Paths.getSparrowAtlas("campaign_menu_UI_assets");

        GameData.unlockedWeeks = [true, true, true, true]; // DEBUG ONLY DO NOT LEAVE IN 
        Highscore.songScores["week1"] = 999120;

        diffSprite = new FlxSprite(903, 65);
        diffSprite.frames = uiFrames;
        diffSprite.animation.addByPrefix("easy", "EASY", 24, false);
        diffSprite.animation.addByPrefix("normal", "NORMAL", 24, false);
        diffSprite.animation.addByPrefix("hard", "NUTS", 24, false);
        diffSprite.animation.play("normal");
        diffSprite.updateHitbox();
        add(diffSprite);
        
        diffArrowL = new DiffArrow(0, 55, uiFrames, true);
        diffArrowL.x = (diffSprite.x - diffArrowL.width) - 10;
        add(diffArrowL);

        diffArrowR = new DiffArrow(0, 55, uiFrames, false);
        diffArrowR.x = (diffSprite.x + diffSprite.width) + 10;
        add(diffArrowR);

        weekSprite = new WeekSprite(875, 200, curWeek+1);
        add(weekSprite);

        scoreTxt = new FlxText(690, 600, 0 , "WEEK SCORE:\n0", 42, false);
        scoreTxt.alignment = CENTER;
        scoreTxt.font = Paths.font("vcr.ttf");
        add(scoreTxt);

        tracksTxt = new FlxText(1010, 530, 0, "TRACKS:\nDonutShop\nAllergy\nAbundance", 42, false);
        tracksTxt.alignment = CENTER;
        tracksTxt.font = Paths.font("vcr.ttf");
        add(tracksTxt);

        /*
        weekSprites = new FlxTypedGroup<WeekSprite>();
        add(weekSprites);

        for (i in 0...GameData.data.weeks.length)
        {
            var data = GameData.data.weeks[i];
            var spr:WeekSprite = new WeekSprite(875, 200 * i, data.week-1);
            weekSprites.add(spr);
        }
        */

        changeDiff();
        changeWeek();

        super.create();
    }

    var stopSpam:Bool = false;
    override function update(elapsed:Float):Void
    {
        super.update(elapsed); 

        if (displayScore != weekScore)
        {
            displayScore = Std.int(FlxMath.lerp(displayScore, weekScore, CoolUtil.boundTo(elapsed * 30, 0, 1)));
            scoreTxt.text = 'WEEK SCORE:\n$displayScore';
        }

        if (controls.UI_LEFT)
            diffArrowL.animation.play("press");
        else
            diffArrowL.animation.play("idle");

        if (controls.UI_RIGHT)
            diffArrowR.animation.play("press");
        else
            diffArrowR.animation.play("idle");

        if (controls.UI_LEFT_P)
            changeDiff(-1);
        if (controls.UI_RIGHT_P)
            changeDiff(1);
        if (controls.UI_DOWN_P)
            changeWeek(1);
        if (controls.UI_UP_P)
            changeWeek(-1);

        if (controls.BACK) 
        {
            FlxG.sound.play(Paths.sound("cancelMenu"));
            MusicBeatState.switchState(new MainMenuState());
        }

        if (controls.ACCEPT && GameData.unlockedWeeks[curWeek]) 
        {
            if (!stopSpam)
            {
                FlxG.sound.play(Paths.sound('confirmMenu'));

                //grpWeekText.members[curWeek].startFlashing();
                stopSpam = true;
            }

            PlayState.storyPlaylist = GameData.data.weeks[curWeek].songs;
            if (curWeek == 2)
                PlayState.storyPlaylist.push("Forgotten"); // secret song
            PlayState.isStoryMode = true;
            //selectedWeek = true;

            PlayState.storyDifficulty = curDiff;

            // adjusting the song name to be compatible
            var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");
            switch (songFormat) {
                case 'Dad-Battle': songFormat = 'Dadbattle';
                case 'Philly-Nice': songFormat = 'Philly';
            }

            var poop:String = Highscore.formatSong(songFormat, curDiff);
            PlayState.campaignMisses = 0;
            PlayState.SONG = Song.loadFromJson(poop, PlayState.storyPlaylist[0]);
            PlayState.storyWeek = curWeek + 1; // Bruh
            PlayState.campaignScore = 0;
            new FlxTimer().start(1, function(tmr:FlxTimer)
            {
                LoadState.loadAndSwitchState(new PlayState());
            });
        }
    }

    function changeDiff(change:Int = 0):Void
    {
        curDiff += change;

        if (curDiff >= CoolUtil.difficultyArray.length)
            curDiff = 0;
        if (curDiff < 0)
            curDiff = CoolUtil.difficultyArray.length - 1;

        diffSprite.offset.set(0, 0);
        diffSprite.animation.play(CoolUtil.difficultyArray[curDiff].toLowerCase());

        switch (curDiff)
        {
            case 0:
                diffSprite.offset.x = -50;

            case 2:
                diffSprite.offset.x = -15;
                diffSprite.offset.y = 18;
        }

        diffSprite.alpha = 0;
        diffSprite.y = 50;

        FlxTween.cancelTweensOf(diffSprite);
        FlxTween.tween(diffSprite, {y: 65, alpha: 1}, 0.07);
    }

    function changeWeek(change:Int = 0):Void
    {
        curWeek += change;

        if (curWeek >= GameData.data.weeks.length)
            curWeek = 0;
        if (curWeek < 0)
            curWeek = GameData.data.weeks.length - 1;

        weekSprite.alpha = 0;
        weekSprite.loadGraphic(GameData.unlockedWeeks[curWeek] ? Paths.image('storymenu/week${GameData.data.weeks[curWeek].week-1}') : Paths.image("storymenu/week-locked"));

        weekSprite.y = (change > 0) ? 175 : 225;
        
        var songs:Array<String> = GameData.data.weeks[curWeek].songs;
        tracksTxt.text = "TRACKS:\n";
        for (song in songs)
        {
            tracksTxt.text += song;
            if (song != songs[songs.length - 1])
                tracksTxt.text += "\n";
        }
        
        //tracksTxt.x = 1010 + (179 - tracksTxt.width);

        FlxTween.cancelTweensOf(weekSprite);
        FlxTween.tween(weekSprite, {y: 200, alpha: 1, "scale.x": 1, "scale.y": 1}, 0.2, {ease: FlxEase.quadInOut});

        if (curWeek == 0 || curWeek == 2 || curWeek == 3) 
            storyBg.swap(StoryBG.DONUT_SHOP_BG);
        else if (curWeek == 1)
            storyBg.swap(StoryBG.VOLCANO_BG);
    }

    private function set_curWeek(value:Int):Int
    {
        curWeek = value;
        weekScore = Highscore.getWeekScore(curWeek, curDiff);
        return value;
    }

    private function set_curDiff(value:Int):Int
    {
        curDiff = value;
        weekScore = Highscore.getWeekScore(curWeek, curDiff);
        return value;
    }
}
