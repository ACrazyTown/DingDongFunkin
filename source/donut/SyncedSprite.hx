package donut;

import flixel.animation.FlxAnimation;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import flixel.FlxSprite;

typedef AnimOptions = 
{
    ?Force:Bool,
    ?Reversed:Bool,
    ?Frame:Int
}

class SyncedSprite extends FlxSprite
{
    /*var anim = animation.curAnim;
    animation.frameIndex = anim.frames[Math.floor(sound.time / sound.length * anim.numFrames)]*/
    public var sound:FlxSound;
    public var soundLength:Float = -1;

    private var shouldSync:Bool = false;

    public function new(X:Float = 0, Y:Float = 0)
    {
        super(X, Y);

        animation.finishCallback = (name:String) -> stop();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (shouldSync && sound != null && sound.playing)
        {
            var anim:FlxAnimation = animation.curAnim;
            var len:Float = (soundLength > -1) ? soundLength : sound.length;
            if (anim != null)
                animation.frameIndex = anim.frames[Math.floor(sound.time / len * anim.numFrames)];
        }
    }

    override function destroy():Void
    {
        sound = null;
        shouldSync = false;
        super.destroy();
    }

    public function updateSound(sound:FlxSoundAsset, loop:Bool = false):Void
    {
        this.sound = new FlxSound();
        this.sound.loadEmbedded(sound, loop);
    }

    public function start(AnimName:String, ?Options:AnimOptions, ?Sound:FlxSoundAsset, ?LoopSound:Bool = false):Void
    {
        if (Options == null)
            Options = {Force: false, Reversed: false, Frame: 0};

        if (Sound != null)
            updateSound(Sound, LoopSound);

        animation.play(AnimName);
        sound.play();
        shouldSync = true;
    }

    public function pause():Void
    {
        shouldSync = false;
        if (animation.curAnim != null)
            animation.pause();
        if (sound != null)
            sound.pause();
    }

    public function stop():Void
    {
        shouldSync = false;
        if (animation.curAnim != null)
            animation.stop();
        if (sound != null)
            sound.stop();
    }
}
