package;

import flixel.FlxSprite;

using StringTools;

class NoteSplash extends FlxSprite
{
    var offsetMap:Map<Int, Array<Int>> = [];

    public function new(X:Float = 0, Y:Float = 0, noteData:Int = 0):Void
    {
        super(X, Y);

        offsetMap.set(0, [-16, -4]); // -32 -11
        offsetMap.set(1, [-52, -40]);

        frames = Paths.getSparrowAtlas("DING_notesplash");

        animation.addByPrefix("note0-0", "left SPLASH", 24, false);
        animation.addByPrefix("note1-0", "down SPLASH", 24, false);
        animation.addByPrefix("note2-0", "up SPLASH", 24, false);
        animation.addByPrefix("note3-0", "right SPLASH", 24, false);

        animation.addByPrefix("note0-1", "splash LEFT", 24, false);
        animation.addByPrefix("note1-1", "splash DOWN", 24, false);
        animation.addByPrefix("note2-1", "splash UP", 24, false);
        animation.addByPrefix("note3-1", "splash RIGHT", 24, false);

        setupSplash(X, Y, noteData);
    }

    public function setupSplash(noteX:Float, noteY:Float, noteData:Int = 0):Void
    {
        setPosition(noteX - Note.swagWidth * 0.95, noteY - Note.swagWidth);
        alpha = 0.85;

        var animNum:Int = FlxG.random.int(0, 1);
        animation.play("note" + noteData + "-" + animNum, true);

        if (animation.curAnim != null)
            animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
        
        var offsets:Array<Int> = offsetMap.get(animNum);
        offset.set(offsets[0], offsets[1]);
    }

    public override function update(elapsed:Float):Void
    {
        if (animation.curAnim != null && animation.curAnim.finished)
            kill();

        super.update(elapsed);
    }
}
