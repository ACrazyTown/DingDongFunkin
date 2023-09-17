package donut.ui;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

class CheckboxOption extends FlxSpriteGroup
{
    private var _text:String = "";

    public var text:FlxText;
    public var checkbox:FlxSprite;

    public var selected:Bool = false;

    public function new(X:Float = 0, Y:Float = 0, text:String):Void
    {
        _text = text;
        super(X, Y);

        this.text = new FlxText(0, 0, 0, _text, 36);
        this.text.setFormat("VCR OSD Mono", 36);
        add(this.text);

        checkbox = new FlxSprite(0, 0);
        checkbox.frames = Paths.getSparrowAtlas("ui/checkbox");
        checkbox.animation.addByPrefix("idle", "box", 24);
        checkbox.animation.addByPrefix("select", "CHECKED", 24, false);
        checkbox.animation.addByPrefix("select_idle", "UNCHECK", 24);
        checkbox.animation.finishCallback = (name:String) -> 
        {
            switch (name)
            {
                case "select":
                    checkbox.animation.play("select_idle");
            }
        }
        checkbox.setGraphicSize(Std.int(checkbox.width * 0.6));
        checkbox.updateHitbox();
        checkbox.setPosition(this.text.x + (this.text.width + checkbox.width), (this.text.height - checkbox.height) / 2);
        checkbox.animation.play("idle");
        add(checkbox);
    }

    public function onClick():Void
    {
        selected = !selected;
        checkbox.animation.play(selected ? "select" : "idle");
    }

    public function updateState(selected:Bool):Void
    {
        this.selected = selected;
        var daAnim:String = selected ? "select" : "idle";

        checkbox.animation.play(daAnim);
    }
}
