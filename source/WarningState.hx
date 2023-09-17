package;

import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.util.FlxColor;
import donut.ui.CheckboxOption;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;

class WarningState extends MusicBeatState
{
    var warningText:FlxText;
    var optionText:FlxText;

    var curSelected:Int = 0;

    var options:Array<String> = ["Flashing Lights", "Shaders", "Save and Proceed"];
    var checkboxGroup:FlxTypedGroup<CheckboxOption>;

    var camFollow:FlxObject;

    override function create():Void
    {
        camFollow = new FlxObject(0, 0, 1, 1);
        camFollow.screenCenter(X);
        FlxG.camera.follow(camFollow, LOCKON, CoolUtil.boundTo((1/120) * 4, 0, 1)); // we can assume it's 1/120 cuz u cant change fps in this state and the default fps is always 120 

        warningText = new FlxText(0, 0, FlxG.width, "WARNING!\nThis mod features flashing lights and intense colors/shaders.\nAdjust these settings to your preferences.", 36);
        warningText.setFormat("VCR OSD Mono", 36, FlxColor.WHITE, CENTER);
        warningText.screenCenter();
        warningText.y -= 240;
        warningText.scrollFactor.set(0, 0);
        add(warningText);

        optionText = new FlxText(warningText.x, warningText.y, 0, "(These settings can be adjusted at any time.)", 24);
        optionText.screenCenter(X);
        optionText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER);
        optionText.y += (warningText.height + 10);
        optionText.scrollFactor.set(0, 0);
        add(optionText);

        var cover:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, Std.int(optionText.y + 10), FlxColor.BLACK);
        cover.scrollFactor.set(0, 0);
        insert(0, cover);

        checkboxGroup = new FlxTypedGroup<CheckboxOption>();
        insert(0, checkboxGroup);

        for (i in 0...options.length)
        {
            var item:CheckboxOption = new CheckboxOption(0, (i * 140), options[i]);
            //item.updateState(true);
            // item.text.y /= 2; // What...
            item.screenCenter(X);
            item.y += 320;
            item.ID = i;

            if (i == options.length - 1)
            {
                item.remove(item.checkbox);
                //item.updateHitbox();
                item.screenCenter(X);
            }

            checkboxGroup.add(item);
        }

        changeSelection();
        super.create();
    }

    override function update(elapsed:Float):Void
    {
        if (controls.ACCEPT)
            accept();
        if (controls.UI_UP_P)
            changeSelection(-1);
        if (controls.UI_DOWN_P)
            changeSelection(1);

        super.update(elapsed);
    }

    function accept():Void
    {
        checkboxGroup.members[curSelected].onClick();

        if (curSelected == options.length - 1)
        {
            FlxG.save.data.flashing = checkboxGroup.members[0].selected;
            FlxG.save.data.useShaders = checkboxGroup.members[1].selected;
            FlxG.save.data.firstBoot = false;
			FlxG.save.flush();

            MusicBeatState.switchState(new TitleState());
        }
    }

    function changeSelection(change:Int = 0):Void
    {
        if (change != 0)
            FlxG.sound.play(Paths.sound("scrollMenu"));

        curSelected += change;

        if (curSelected >= options.length)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = options.length - 1;

        checkboxGroup.forEach((spr:CheckboxOption) -> 
        {
            spr.alpha = 0.6;

            if (spr.ID == curSelected)
            {
                camFollow.y = spr.y;
                spr.alpha = 1;
            }
        });
    }
}
