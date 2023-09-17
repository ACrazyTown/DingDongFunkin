package;

import flixel.FlxSprite;
import donut.ui.AchievementObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import donut.achievement.AchievementData;

class AchievementState extends MusicBeatState
{
    var achievementGroup:FlxTypedGroup<AchievementObject>;
    var curSelected:Int = 0;

    override function create():Void
    {
        var background:FlxSprite = new FlxSprite(0, 0, Paths.image("menu/freeplayBGDesat"));
		background.color = MainMenuState.mainColor;
        background.active = false;
        add(background);

        achievementGroup = new FlxTypedGroup<AchievementObject>();
        add(achievementGroup);

        var i:Int = 0; // dat manual for loop be like 🥵🥵
        for (id in AchievementData.sortedList)
        {
            var data:GlobalAchievement = AchievementData.achievements.get(id);

            var item:AchievementObject = new AchievementObject(0, 0, data.id);
            item.targetY = i;
            item.screenCenter(X);
            item.y += (i * 160) + ((FlxG.height - item.height) / 2);
            achievementGroup.add(item);

            i++;
        }

        changeOption();
        super.create();
    }

    override function update(elapsed:Float):Void
    {
        if (controls.BACK)
        {
            FlxG.sound.play(Paths.sound("cancelMenu"));
            MusicBeatState.switchState(new MainMenuState());
        }

        if (controls.UI_UP_P)
            changeOption(-1);
        if (controls.UI_DOWN_P)
            changeOption(1);

        super.update(elapsed);
    }

    function changeOption(change:Int = 0):Void
    {
        if (change != 0) // dont play scroll when creating
            FlxG.sound.play(Paths.sound('scrollMenu'));

        curSelected += change;

        if (curSelected >= achievementGroup.length)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = achievementGroup.length - 1;

        var tracker:Int = 0;
        achievementGroup.forEach((item:AchievementObject) -> 
        {
            item.targetY = tracker - curSelected;
            item.alpha = 0.7;

            if (item.targetY == 0)
                item.alpha = 1;

            tracker++;
        });
    }
}
