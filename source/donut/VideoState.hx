package donut;

import flixel.tweens.FlxTween;
import flixel.addons.transition.FlxTransitionableState;
import flixel.text.FlxText;
import hxcodec.flixel.FlxVideoSprite;
import flixel.FlxState;

class VideoState extends FlxState
{
    var video:FlxVideoSprite;
    var skipText:FlxText;

    var videoPath:String;
    var nextState:FlxState;

    var debug:FlxText;
    var dbgCount:Bool = true;
    var dbgTimer:Float = 0;

    public function new(path:String, nextState:FlxState)
    {
        super();

        videoPath = path;
        this.nextState = nextState;
    }

    override function create():Void
    {
        bgColor = 0xFF000000;

        Main.toggleFPS(false);

        debug = new FlxText(0, 0, 0, ":(", 24);
        debug.screenCenter();
        add(debug);

        video = new FlxVideoSprite(0, -16); // Videos like playing at 1280x736 for whatever reason, fuck you
        video.bitmap.onEndReached.add(onVideoFinish);
        video.bitmap.onPlaying.add(() ->
        {
            video.visible = true;
            video.bitmap.volume = Std.int(FlxG.sound.volume * 100);
            trace(video.bitmap.videoHeight);
            dbgCount = false;
        });
        video.visible = false;
        add(video);

        skipText = new FlxText(0, 0, 0, "Press ENTER to skip", 28);
        skipText.font = Paths.font("vcr.ttf");
        skipText.setBorderStyle(OUTLINE, 0xFF000000, 1.5);
        skipText.x = 5;
        skipText.y = FlxG.height - skipText.height - 5;
        add(skipText);

        video.play(videoPath);

        FlxTween.tween(skipText, {alpha: 0}, 2, {startDelay: 5});
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (dbgCount) {
            dbgTimer += elapsed;
            debug.text = "video should play anytime now" + "\n" + dbgTimer;
            debug.screenCenter();
        }

        if (FlxG.keys.justPressed.ENTER)
            onVideoFinish();
    }

    function onVideoFinish():Void
    {
        Main.toggleFPS(true);

        video.stop();
        video.bitmap.dispose();

        //skipText.visible = false;

        if (nextState != null) {
            FlxTransitionableState.skipNextTransIn = true;
            FlxTransitionableState.skipNextTransOut = true;
            FlxG.switchState(nextState);
        }
        else
            trace("I'M STUCK");
    }
}