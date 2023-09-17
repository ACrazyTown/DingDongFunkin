package donut.achievement;

import openfl.events.Event;
import donut.achievement.AchievementData.GlobalAchievement;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.Assets;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.Sprite;

class AchievementSprite extends Sprite 
{
    public static var _width:Int = 322;
    public static var _height:Int = 110;

    public var box:Bitmap;
    var icon:Bitmap;
    var text:TextField;

    public function new():Void
    {
        super();

        var boxBd:BitmapData = new BitmapData(_width, _height, false, FlxColor.BLACK);
        //boxBd.fillRect(new openfl.geom.Rectangle(x, y, _width, _height), FlxColor.BLACK);
        box = new Bitmap(boxBd);
        box.x = x;
        box.y = y;
        addChild(box);

        var iconBd:BitmapData = Assets.getBitmapData(Paths.image("achievement/unknown"));
        icon = new Bitmap(iconBd);
        icon.x = 15;
        icon.y = (box.height - icon.height) / 2;
        addChild(icon);

        text = new TextField();
        text.selectable = false;
        text.defaultTextFormat = new TextFormat("VCR OSD Mono", 16, FlxColor.WHITE, null, null, null, null, null, CENTER);
        //text.wordWrap = true;
        text.multiline = true;
        text.text = "Achievement Unlocked\n\nUnknown";
        // text.setPosition(icon.x + (icon.width + 2), box.y + 28);
        text.width = 240;
        text.x = icon.x + (icon.width + 2);
        text.y = 28;
        addChild(text);
    }

    public function recalcPosition(newX:Float = 0/*, ?newY:Float*/):Void
    {
        box.x = newX;
        //box.y = newY;

        icon.x = box.x + 15;
        icon.y = box.y + (box.height - icon.height) / 2;

        text.x = icon.x + (icon.width + 2);
        text.y = box.y + 28;
    }

    public function update(achievementId:String):Void
    {
        var data:GlobalAchievement = AchievementData.achievements.get(achievementId);
        if (data == null)
        {
            text.text = "Achievement Unlocked\n\nUnknown";
            updateIcon("unknown");
        }
        else
        {
            text.text = 'Achievement Unlocked\n\n${data.name}';
            updateIcon(data.id);
        }
    }

    private function updateIcon(id:String):Void
    {
        var path:String = Paths.assetPath('achievement/$id', null, IMAGE);
        if (!Assets.exists(path)) 
        {
            icon.bitmapData.dispose();
            icon = new Bitmap(Assets.getBitmapData(Paths.assetPath('achievement/unknown', null, IMAGE)));
            return;
        }

        icon.bitmapData.dispose();
        icon = new Bitmap(Assets.getBitmapData(Paths.assetPath('achievement/$id', null, IMAGE)));
    }
}
