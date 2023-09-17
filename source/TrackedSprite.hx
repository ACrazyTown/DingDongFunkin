package;

import flixel.util.FlxAxes;
import flixel.text.FlxText;
import flixel.FlxSprite;

class TrackedSprite extends FlxSprite
{
    public var spriteTracker(default, set):FlxSprite;

    public var xOffset:Float = 0;
    public var yOffset:Float = 0;

    public var followAxes:FlxAxes = XY;

    override function update(elapsed:Float):Void
    {
        if (spriteTracker != null)
        {
            if (followAxes == FlxAxes.X || followAxes == FlxAxes.XY)
                x = spriteTracker.x + spriteTracker.width + xOffset;
            if (followAxes == FlxAxes.Y || followAxes == FlxAxes.XY)
                y = spriteTracker.y - yOffset;
        }

        super.update(elapsed);
    }

    private function set_spriteTracker(tracker:FlxSprite):FlxSprite
    {
        if (spriteTracker != null && spriteTracker != tracker)
            spriteTracker.destroy();

        return spriteTracker = tracker;
    }

    override function destroy():Void
    {
        if (spriteTracker != null)
            spriteTracker.destroy();
        super.destroy();
    }
}

class TrackedText extends FlxText
{
    public var spriteTracker(default, set):FlxSprite;

    public var xOffset:Float = 0;
    public var yOffset:Float = 0;

    public var followAxes:FlxAxes = XY;

    override function update(elapsed:Float):Void
    {
        if (spriteTracker != null)
        {
            if (followAxes == FlxAxes.X || followAxes == FlxAxes.XY)
                x = spriteTracker.x + spriteTracker.width + xOffset;
            if (followAxes == FlxAxes.Y || followAxes == FlxAxes.XY)
                y = spriteTracker.y - yOffset;
        }

        super.update(elapsed);
    }

    private function set_spriteTracker(tracker:FlxSprite):FlxSprite
    {
        if (spriteTracker != null && spriteTracker != tracker)
            spriteTracker.destroy();

        return spriteTracker = tracker;
    }

    override function destroy():Void
    {
        if (spriteTracker != null)
            spriteTracker.destroy();
        super.destroy();
    }
}