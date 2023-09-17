package;

import flixel.math.FlxMath;
import TrackedSprite.TrackedText;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxSubState;

using StringTools;

class KeyBindMenu extends FlxSubState
{
    var curSelected:Int = 0;
    var curItem:Int = 0;

    // 0 - text, 1 - id
    var keyData:Array<Array<String>> = [
        ["UI LEFT", "ui_left"],
        ["UI DOWN", "ui_down"],
        ["UI UP", "ui_up"],
        ["UI RIGHT", "ui_right"],
        ["NOTE LEFT", "note_left"],
        ["NOTE DOWN", "note_down"],
        ["NOTE UP", "note_up"],
        ["NOTE RIGHT", "note_right"],
        ["ACCEPT", "accept"],
        ["BACK", "back"],
        ["PAUSE", "pause"],
        ["RESET", "reset"]
    ];

    var textGroup:FlxTypedGroup<FlxText>;
    var optionGroup:FlxTypedGroup<TrackedText>;
    var optionGroupAlt:FlxTypedGroup<TrackedText>;

    var remapping:Bool = false;

    public function new()
    {
        super();

        var bg:FlxSprite = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
        bg.alpha = 0.7;
        add(bg);

        textGroup = new FlxTypedGroup<FlxText>();
        add(textGroup);

        optionGroup = new FlxTypedGroup<TrackedText>();
        add(optionGroup);

        optionGroupAlt = new FlxTypedGroup<TrackedText>();
        add(optionGroupAlt);

        for (i in 0...keyData.length)
        {
            var option:FlxText = new FlxText(100, i * 42, 0, keyData[i][0], 54);
            option.font = Paths.font("vcr.ttf");
            option.setBorderStyle(OUTLINE, FlxColor.BLACK, 4);
            option.ID = i;
            textGroup.add(option);

            var keys:Array<FlxKey> = KeyBinds.keyBinds.get(keyData[i][1]);
            var key:TrackedText = new TrackedText(600, option.y, 0, CoolUtil.formatKey(keys[0]), 54);
            key.font = Paths.font("vcr.ttf");
            key.setBorderStyle(OUTLINE, FlxColor.BLACK, 4);
            key.followAxes = Y;
            key.spriteTracker = option;
            optionGroup.add(key);

            var keyAlt:TrackedText = new TrackedText(1000, option.y, 0, CoolUtil.formatKey(keys[1]), 54);
            keyAlt.font = Paths.font("vcr.ttf");
            keyAlt.setBorderStyle(OUTLINE, FlxColor.BLACK, 4);
            keyAlt.followAxes = Y;
            keyAlt.spriteTracker = option;
            optionGroupAlt.add(keyAlt);
        }

        var cover:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(1280, 26, FlxColor.BLACK);
        cover.alpha = 0.6;
        add(cover);

        var helpText:FlxText = new FlxText(0, FlxG.height - 21, 0, "Press R to reset keybinds to default.", 16);
        helpText.font = Paths.font("vcr.ttf");
        helpText.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
        add(helpText);

        changeSelection();
    }

    override function update(elapsed:Float):Void
    {
        if (remapping)
        {
            if (FlxG.keys.firstJustPressed() != FlxKey.NONE)
            {
                var key:FlxKey = FlxG.keys.firstJustPressed();

                FlxG.sound.play(Paths.sound("confirmMenu"));

                var curKeys:Array<FlxKey> = KeyBinds.keyBinds.get(keyData[curSelected][1]);
                curKeys[curItem] = key;
                
                //AHHHHHHHHH IT HURTS
                if (curKeys[0] == curKeys[1])
                    (curItem == 0) ? curKeys[1] = -1 : curKeys[0] = -1;

                KeyBinds.keyBinds.set(keyData[curSelected][1], curKeys);
                KeyBinds.debug();

                var daGroup:FlxTypedGroup<TrackedText> = (curItem == 0) ? optionGroup : optionGroupAlt;
                daGroup.members[curSelected].text = CoolUtil.formatKey(key);
                daGroup.members[curSelected].visible = true;

                // INVALID NONE TYPE KEY, LETS REFRESH !!!
                if (curKeys.contains(-1))
                {
                    optionGroup.members[curSelected].text = CoolUtil.formatKey(curKeys[0]);
                    optionGroupAlt.members[curSelected].text = CoolUtil.formatKey(curKeys[1]);
                }

                remapping = false;
            }
        }
        else
        {
            if (FlxG.keys.justPressed.ESCAPE)
            {
                KeyBinds.save();
                
                FlxG.sound.play(Paths.sound("cancelMenu"));
                close();
            }
    
            if (FlxG.keys.anyJustPressed([W, UP]))
                changeSelection(-1);
            if (FlxG.keys.anyJustPressed([S, DOWN]))
                changeSelection(1);
            if (FlxG.keys.anyJustPressed([D, RIGHT]))
                changeItem(1);
            if (FlxG.keys.anyJustPressed([A, LEFT]))
                changeItem(-1);

            if (FlxG.keys.justPressed.ENTER)
            {
                FlxG.sound.play(Paths.sound("scrollMenu"));
    
                var daGroup:FlxTypedGroup<TrackedText> = curItem == 0 ? optionGroup : optionGroupAlt;
                daGroup.members[curSelected].visible = false;
    
                remapping = true;
            }

            if (FlxG.keys.justPressed.R)
            {
                KeyBinds.reset();
    
                trace("New KeyBind\n" + KeyBinds.keyBinds);
                trace("Def Keybind\n" + KeyBinds.defaultBinds);

                for (i in 0...keyData.length)
                {
                    var keys:Array<FlxKey> = KeyBinds.keyBinds.get(keyData[i][1]);

                    optionGroup.members[i].text = CoolUtil.formatKey(keys[0]);
                    optionGroupAlt.members[i].text = CoolUtil.formatKey(keys[1]);
                }
            }
        }

        textGroup.forEach((txt:FlxText) -> 
        {
            var targetY:Int = textGroup.members.indexOf(txt) - curSelected;
            txt.y = FlxMath.lerp(txt.y, ((FlxG.height - txt.height) / 2) + targetY * 64, CoolUtil.boundTo(elapsed * 8, 0, 1));
        });

        super.update(elapsed);
    }

    function changeSelection(change:Int = 0)
    {
        if (change != 0)
            FlxG.sound.play(Paths.sound("scrollMenu"));

        curSelected += change;

        if (curSelected > keyData.length - 1)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = keyData.length - 1;

        textGroup.forEach((txt:FlxText) -> 
        {
            txt.color = FlxColor.WHITE;

            if (txt.ID == curSelected)
                txt.color = FlxColor.YELLOW;
        });

        updateGroups();
    }

    function changeItem(change:Int = 0)
    {
        if (change != 0)
            FlxG.sound.play(Paths.sound("scrollMenu"));

        curItem += change;

        if (curItem > 1)
            curItem = 0;
        if (curItem < 0)
            curItem = 1;

        updateGroups();
    }

    function updateGroups():Void
    {
        var selectedItem:FlxText = textGroup.members[curSelected];
        optionGroup.forEach((opt:TrackedText) -> 
        {
            opt.color = FlxColor.WHITE;

            if (opt.spriteTracker == selectedItem && curItem == 0)
                opt.color = FlxColor.YELLOW;
        });

        optionGroupAlt.forEach((opt:TrackedText) -> 
        {
            opt.color = FlxColor.WHITE;

            if (opt.spriteTracker == selectedItem && curItem == 1)
                opt.color = FlxColor.YELLOW;
        });
    }
}