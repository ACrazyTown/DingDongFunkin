package;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.util.FlxGradient;
import flixel.group.FlxSpriteGroup;

class DingBg extends FlxSpriteGroup
{
    public var background:FlxSprite;
    public var gradient:FlxSprite;

    public function new() 
    {
        super(0, 0);

        background = new FlxSprite(0, 0, Paths.image("menu/freeplayBGDesat"));
		background.color = MainMenuState.mainColor;
        background.active = false;
        add(background);

        gradient = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [FlxColor.TRANSPARENT, MainMenuState.subtractColor], 1);
        gradient.alpha = 0.5;
        gradient.blend = SCREEN;
        add(gradient);
    }
}
