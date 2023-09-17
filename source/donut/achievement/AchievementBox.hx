package donut.achievement;

import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import donut.achievement.AchievementData.GlobalAchievement;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import openfl.Assets;

class AchievementBox extends FlxSpriteGroup
{
    private var _width:Int = 322; // 158
    private var _height:Int = 110; //64

    public var regX:Float = 0;
    public var regY:Float = 0;

    public var popupY:Float = 0;

    private var box:FlxSprite;
    private var text:FlxText;
    private var icon:FlxSprite;

    public function new(id:String)
    {
        super();

        regX = FlxG.width - _width;
        regY = FlxG.save.data.achievementPosUp ? -_height : FlxG.height;

        popupY = FlxG.save.data.achievementPosUp ? 0 : FlxG.height - _height; // The pos where its supposed to show up

        box = new FlxSprite(x, y).makeGraphic(_width, _height, FlxColor.BLACK);

        icon = new FlxSprite(0, 0);
        icon.loadGraphic(Paths.image("achievement/unknown"));
        icon.setPosition(x + 15, box.y + (box.height - icon.height) / 2);

        // +4
        text = new FlxText(0, 0, 240, "Achievement Unlocked\n\nUnknown", 16);
        text.setPosition(icon.x + (icon.width + 2), box.y + 28);
        text.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER);

        updateAchievement(id);

        x = regX;
        y = regY;

        add(box);
        add(icon);
        add(text);
    }

    public function updateAchievement(achievementID:String):Void
    {
        var data:GlobalAchievement = AchievementData.achievements.get(achievementID);

        if (data == null)
        {
            text.text = "Achievement Unlocked\n\nUnknown";
            updateIcon(Paths.imagePath("achievement/unknown"));
        }
        else
        {
            text.text = "Achievement Unlocked\n\n" + data.name;
            trace(Paths.image("achievement/" + data.id));
            trace(data.id);
            updateIcon(Paths.imagePath("achievement/" + data.id));
        }
    }

    public function popup(destroy:Bool = false):Void 
    {
        FlxG.sound.play(Paths.sound("achievementUnlock", "preload"), 0.6);

        // ugh ugh ugh ugh
        FlxTween.tween(this, {y: popupY}, 0.75, {ease: FlxEase.quadInOut, onComplete: (t:FlxTween) -> 
        {
            new FlxTimer().start(5, (t:FlxTimer) -> 
            {
                FlxTween.tween(this, {y: regY}, 0.75, {ease: FlxEase.quadInOut, onComplete: (t:FlxTween) ->
                {
                    if (destroy)
                        this.destroy();
                    t.destroy(); // uhh
                }});
                t.destroy(); // uhh
            });
            t.destroy(); // uhh
        }});
    }

    private function updateIcon(path:String):Void
    {
        if (!Assets.exists(path))
            icon.loadGraphic(Paths.image("achievement/unknown"));
        else
            icon.loadGraphic(path);
        icon.setPosition(x + 15, box.y + (box.height - icon.height) / 2);
    }
}
