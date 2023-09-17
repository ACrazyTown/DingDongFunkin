package;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxSprite;

@:enum abstract CutsceneEventType(String)
{
    var FRAME = "frame";
    var STEP = "step";
    var BEAT = "beat";
}

typedef CutsceneEvent = 
{
    type:CutsceneEventType,
    func:Void->Void,
    ?anim:String,
    ?song:String, // SONG IS UNUSED. LOCKS ON TO THE CUR PLAYING MUSIC
    ?beat:Int,
    ?step:Int,
    ?frame:Int
}

class CutsceneSprite extends FlxSprite
{
    public var animOffsets:Map<String, Array<Float>> = [];
    var events:Array<CutsceneEvent> = [];

    public function new(x:Float = 0, y:Float = 0, ?frames:FlxAtlasFrames)
    {
        super(x, y);

        if (frames != null)
            this.frames = frames;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        for (event in events)
        {
            switch (event.type)
            {
                case FRAME:
                    if (animation.curAnim != null && animation.curAnim.name == event.anim 
                        && animation.curAnim.curFrame == event.frame)
                    {
                        event.func();
                        events.remove(event);
                    }

                case BEAT:
                    if (Reflect.hasField(FlxG.state, "curBeat")) 
                    {
                        if (cast(FlxG.state, MusicBeatState).curBeat == event.beat)
                        {
                            event.func();
                            events.remove(event);
                        }
                    }

                case STEP:
                    if (Reflect.hasField(FlxG.state, "curStep")) 
                    {
                        if (cast(FlxG.state, MusicBeatState).curStep == event.step)
                        {
                            event.func();
                            events.remove(event);
                        }
                    }        
            }
        }
    }

    override function destroy():Void
    {
        super.destroy();
        animOffsets.clear();
        animOffsets = null;
        events = null;
    }

    public function addAnim(name:String, prefix:String, fps:Int = 24, looped:Bool = false, ?offset:Array<Float>):Void
    {
        animation.addByPrefix(name, prefix, fps, looped);
        animOffsets.set(name, offset == null ? [0, 0] : offset);
    }

    public function addFrameEvent(anim:String, frame:Int, func:Void->Void):Void
    {
        if (!animation.getNameList().contains(anim) || func == null)
            return;

        events.push({
            type: FRAME,
            anim: anim,
            func: func,
            frame: frame
        });
    }

    public function addBeatEvent(beat:Int, func:Void->Void):Void
    {
        if (func == null)
            return;

        events.push({
            type: BEAT,
            func: func,
            beat: beat
        });
    }

    public function addStepEvent(step:Int, func:Void->Void):Void
    {
        if (func == null)
            return;

        events.push({
            type: BEAT,
            func: func,
            step: step
        });
    }

    public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0):Void
    {
        animation.play(name, force, reversed, frame);

        var daOffset:Array<Float> = animOffsets.exists(name) ? animOffsets.get(name) : [0, 0];
        offset.set(daOffset[0], daOffset[1]);
    }
}