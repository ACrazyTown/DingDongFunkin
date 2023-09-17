package;

import flixel.FlxSprite;

class StageSprite extends FlxSprite
{
    var idle:String = null;

    public function new(X:Float = 0, Y:Float = 0, name:String, library:String = null, 
        anims:Array<String>, loop:Bool, scrollX:Float = 1, scrollY:Float = 1)
    {
        super(X, Y);

        if (anims != null)
        {
            frames = Paths.getSparrowAtlas(name, library);

            for (anim in anims)
            {
                animation.addByPrefix(anim, anim, 24, loop);
                if (idle == null)
                {
                    idle = anim;
                    animation.play(anim);
                }
            }
        }
        else
        {
            if (name != null)
                loadGraphic(Paths.image(name, library));
            active = false;
        }

        scrollFactor.set(scrollX, scrollY);
    }

    public function dance(?force:Bool = false):Void
    {
        if (idle != null)
            animation.play(idle, force);
    }
}
