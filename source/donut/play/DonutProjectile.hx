package donut.play;

import flixel.FlxSprite;

class DonutProjectile extends FlxSprite
{
    public function new(X:Float = 0, Y:Float = 0)
    {
        super(X, Y);

        makeGraphic(96, 96);
    }
}
