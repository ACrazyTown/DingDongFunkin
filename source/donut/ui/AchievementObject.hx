package donut.ui;

import flixel.math.FlxMath;
import flixel.util.FlxColor;
import openfl.utils.Assets;
import flixel.FlxSprite;
import flixel.text.FlxText;
import donut.achievement.AchievementData;
import donut.achievement.AchievementData.GlobalAchievement;
import flixel.group.FlxSpriteGroup;

class AchievementObject extends FlxSpriteGroup
{
    private var data:GlobalAchievement;

    public var targetY:Int = 0;

    public var container:FlxSprite;
    public var icon:FlxSprite;
    
    public var title:FlxText;
    public var description:FlxText;

    public function new(x:Float = 0, y:Float = 0, id:String):Void
    {
        super(x, y);

        data = AchievementData.achievements.get(id);
        if (data == null)
            data = AchievementData.achievements.get("unknown");

        container = new FlxSprite(x, y).makeGraphic(625, 166, FlxColor.BLACK);

        icon = new FlxSprite(x, y).loadGraphic(Paths.image("achievement/unknown"));
        icon.scrollFactor.set();
        updateIcon(Paths.assetPath('achievement/${data.id}', null, IMAGE));

        title = new FlxText(x, y, 0, (data.secret && !AchievementData.isUnlocked(id)) ? "???" : data.name, 36);
        title.setFormat("VCR OSD Mono", 36);
        title.scrollFactor.set();

        description = new FlxText(x, y, 0, (data.secret && !AchievementData.isUnlocked(id)) ? "???" : data.description, 18);
        description.setFormat("VCR OSD Mono", 18);
        description.scrollFactor.set();

        title.x = container.x + ((container.width - (icon.width + 40)) - title.width);
        title.y = icon.y;
        description.x = container.x + ((container.width - (icon.width + 40)) - description.width);
        description.y = title.y + (title.height + description.height) + 5;

        add(container);
        add(icon);
        add(title);
        add(description);
    }

    override function update(elapsed:Float):Void
    {
        y = FlxMath.lerp(y, (targetY * 265) + ((FlxG.height - container.frameHeight) / 2), CoolUtil.boundTo(elapsed*9.6, 0, 1)); // container is the max size so use that?
        super.update(elapsed);
    }

    private function updateIcon(path:String):Void
    {
        if (!Assets.exists(path))
            icon.loadGraphic(Paths.image("achievement/unknown"));
        else
            icon.loadGraphic(path);

        icon.setGraphicSize(Std.int(icon.width * 1.5));
        icon.updateHitbox();
        icon.setPosition(x + 20, container.y + (container.height - icon.height) / 2);
    }
}
