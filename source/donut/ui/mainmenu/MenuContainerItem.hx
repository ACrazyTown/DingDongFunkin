package donut.ui.mainmenu;

import openfl.utils.Assets;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

using StringTools;

class MenuContainerItem extends FlxSpriteGroup
{
    private var _text:String = "";
    private var _id:String = "";

    private var container:FlxSprite;
    private var image:FlxSprite;
    private var text:FlxText;

    public var targetX:Int = 0;
    public var targetY:Float = 0;

    public function new(X:Float = 0, Y:Float = 0, name:String = "Story Mode", ?targetX:Int = 0)
    {
        this.targetX = targetX;

        var reg:EReg = ~/\s/g;
        super(X, Y);

        _text = name;
        _id = reg.replace(_text, '').toLowerCase();

        //432-532-0xFF000033
        container = new FlxSprite(X, Y).loadGraphic(Paths.image("ui/container", "preload"));
        // OFL.exists("menu/"_id, IMAGE) ? Paths.image("menu/" + _id) : Paths.image("menu/container_default")
        image = new FlxSprite(X, Y).loadGraphic(Assets.exists("ui/" + _id, IMAGE) ? Paths.image("ui/" + _id, "preload") : Paths.image("ui/container_default", "preload"));
        text = new FlxText(X, Y, 0, name.toUpperCase(), 58);
        text.font = "VCR OSD Mono";

        // if the text is wider than the container (-20 for cleanliness reaons!!!), replace the first space
        // with a new line?
        if (text.width > (container.width - 20))
            text.text.replace(" ", "\n");

        // icon.setPosition(x + 15, box.y + (box.height - icon.height) / 2); ref
        // re positioning because FUCK sprite group
        image.setPosition(container.x + (container.width - image.width) / 2, y + 60);
        text.setPosition(container.x + (container.width - text.width) / 2, (image.y + text.height) + 260);

        add(container);
        add(image);
        add(text);
    }

    override function update(elapsed:Float):Void
    {
        var lv1:Float = CoolUtil.boundTo(elapsed * 8.3, 0, 1);
        var lv2:Float = CoolUtil.boundTo(elapsed * 6.5, 0, 1);

        x = FlxMath.lerp(x, ((targetX * 600) + FlxG.width / 2) - width / 2, lv1);
        y = FlxMath.lerp(y, targetY, lv1);
        angle = FlxMath.lerp(angle, targetX * 7.5, lv2);
        super.update(elapsed);
    }
}
