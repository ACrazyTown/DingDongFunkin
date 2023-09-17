package;

import openfl.net.FileFilter;
import haxe.Json;
import Character.CharacterFile;
import Character.AnimationData;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI;
import flixel.FlxCamera;
import flixel.addons.ui.FlxUITabMenu;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import openfl.net.FileReference;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import flixel.addons.display.FlxGridOverlay;
import flixel.FlxSprite;

using StringTools;

class OffsetTool extends MusicBeatState
{
    var _file:FileReference;

    var uiBox:FlxUITabMenu;

    var camUI:FlxCamera;

    var base:FlxSprite;
    var char:FlxSprite;
    var charOffset:Map<String, Array<Float>> = [];

    var offsetTxt:FlxText;
    var canEditTxt:FlxText;

    override function create():Void
    {
        var bg:FlxSprite = FlxGridOverlay.create(10, 10, FlxG.width, FlxG.height);
        add(bg);

        #if debug
        FlxG.console.registerClass(Paths);
        FlxG.console.registerFunction("loadCharShit", (atlas:FlxAtlasFrames, ?swapBase:Bool = false) -> 
        {
            if (char != null)
            {
                remove(char);
                char = null;
            }

            if (swapBase)
            {
                if (base != null)
                {
                    remove(base);
                    base = null;
                }

                base = new FlxSprite(100, 100);
                base.frames = atlas;
                base.visible = false;
            }

            char = new FlxSprite(100, 100);
            char.frames = atlas;

            if (swapBase)
                add(base);
            add(char);
        });

        FlxG.console.registerFunction("shaderTestCam", (LmfaoValue:Float = 0.0) -> 
        {
            @:privateAccess
            if (FlxG.game._filters != null && FlxG.game._filters.length > 0)
                FlxG.game._filters = [];

            //CoolUtil.pushCamFilters(FlxG.camera, [new ShaderFilter(new FisheyeShader())]);
            FlxG.camera.setFilters([new openfl.filters.ShaderFilter(new donut.shader.FisheyeShader(LmfaoValue))]);
        });

        FlxG.console.registerFunction("shaderTestGame", () ->
        {
            @:privateAccess
            if (FlxG.camera._filters != null && FlxG.camera._filters.length > 0)
                FlxG.camera._filters = [];

            FlxG.game.setFilters([new openfl.filters.ShaderFilter(new donut.shader.FisheyeShader())]);
        });
        #end

        camUI = new FlxCamera();
        camUI.bgColor.alpha = 0;
        FlxG.cameras.add(camUI, false);

        base = new FlxSprite(100, 100);
        base.frames = Paths.getSparrowAtlas("characters/bf/bf", "shared");
        base.visible = false;
        add(base);

        char = new FlxSprite(100, 100);
        char.frames = Paths.getSparrowAtlas("characters/bf/bf", "shared");
        add(char);       

        FlxG.stage.window.onDropFile.add((p:String) -> 
        {
            if (char != null)
            {
                remove(char);
                char = null;
            }

            if (base != null)
            {
                remove(base);
                base = null;
            }

            var graph:FlxGraphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(p));
            var xmlPath:String = p.replace("\\", "/").replace(".png", ".xml");

            _file = new FileReference();
            _file.addEventListener(Event.SELECT, (e:Event) -> 
            {
                _file.load();
                xmlPath = _file.data.toString();

                //trace(xmlPath);

                charOffset.clear();
                trackedAnims = [];

                char = new FlxSprite(100, 100);
                char.frames = FlxAtlasFrames.fromSparrow(graph, xmlPath);
                add(char);

                base = new FlxSprite(100, 100);
                base.frames = FlxAtlasFrames.fromSparrow(graph, xmlPath);
                insert(members.indexOf(char), base);
            });
            _file.browse([new FileFilter("Sparrow XML for the Image", "xml")]);

           // Assets.
        });

        uiBox = new FlxUITabMenu(null, [
            {name: "Animation", label: "Animation"},
            {name: "Offsets", label: "Offsets"},
            {name: "Export", label: "Export"}
        ], true);
        uiBox.resize(300, 400);
        uiBox.x = FlxG.width - uiBox.width;
        uiBox.scrollFactor.set();
        uiBox.cameras = [camUI];
        add(uiBox);

        createAnimTab();
        createOffsetTab();
        createExportTab();

        offsetTxt = new FlxText(0, 0, 0, "Anim:null\nX:null\nY:null\n", 24);
        offsetTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 4);
        offsetTxt.setPosition(FlxG.width - offsetTxt.width - 15, 410);
        offsetTxt.cameras = [camUI];
        offsetTxt.scrollFactor.set();
        add(offsetTxt);

        canEditTxt = new FlxText(0, 0, 0, "false", 24);
        canEditTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 4);
        canEditTxt.setPosition(offsetTxt.x - canEditTxt.width - 15, 410);
        canEditTxt.cameras = [camUI];
        canEditTxt.scrollFactor.set();
        add(canEditTxt);

        if (FlxG.sound.music != null && FlxG.sound.music.playing)
            FlxG.sound.music.stop();

        FlxG.mouse.visible = true;
        super.create();
    }

    var trackedAnims:Array<AnimationData> = [];
    var curAnim:String;
    var animListText:FlxText;

    var animUI:FlxUI;
    var animNameTxt:FlxInputText;
    var animPrefixTxt:FlxInputText;
    var animFps:FlxUINumericStepper;
    var animLoop:FlxUICheckBox;
    var animLoopReal:FlxUICheckBox;
    var animIndices:FlxInputText;
    var addAnimBtn:FlxButton;
    var animsDropdown:FlxUIDropDownMenu;

    var baseAnimInput:FlxInputText;
    var basePlayCheckbox:FlxUICheckBox;

    function createAnimTab():Void
    {
        animUI = new FlxUI(null, uiBox);
        animUI.name = "Animation";
        
        animNameTxt = new FlxInputText(10, 10, 50);
        animUI.add(animNameTxt);

        animPrefixTxt = new FlxInputText(70, 10, 150);
        animUI.add(animPrefixTxt);

        animFps = new FlxUINumericStepper(230, 10, 1, 24, 0);
        animUI.add(animFps);

        animLoop = new FlxUICheckBox(0, 30, null, null, "Loop (Editor)", 100);
        animUI.add(animLoop);

        animLoopReal = new FlxUICheckBox(0, 55, null, null, "Loop", 100);
        animUI.add(animLoopReal);

        animIndices = new FlxInputText(10, 30, 150);
        animUI.add(animIndices);

        animLoopReal.x = animLoop.x = animIndices.y + animIndices.width + 10;

        addAnimBtn = new FlxButton(10, 60, "Add Anim", addAnim);
        animUI.add(addAnimBtn);

        animsDropdown = new FlxUIDropDownMenu(10, 90, FlxUIDropDownMenu.makeStrIdLabelArray(["ADD ANIM FIRST DO NOT PLAY"], true), (a:String) ->
        {
            curAnim = a;
        });
        animUI.add(animsDropdown);

        var playAnimBtn = new FlxButton(140, 90, "Play Anim", () -> 
        {
            if (char != null)
                playAnim(curAnim);
        });
        animUI.add(playAnimBtn);

        basePlayCheckbox = new FlxUICheckBox(70, 140, null, null, "Base should play");
        animUI.add(basePlayCheckbox);

        animListText = new FlxText(10, 160, 0, "Animations:");
        animUI.add(animListText);

        var baseAnimTxt = new FlxText(10, 120, 0, "BaseAnim");
        baseAnimInput = new FlxInputText(10, 140, 50);
        animUI.add(baseAnimTxt);
        animUI.add(baseAnimInput);

        var showBase = new FlxUICheckBox(70, 120, null, null, "Show Base Anim");
        showBase.callback = () -> base.visible = showBase.checked;
        animUI.add(showBase);

        uiBox.addGroup(animUI);
    }

    var offsetUI:FlxUI;
    var offsetXInput:FlxInputText;
    var offsetYInput:FlxInputText;
    var offsetListText:FlxText;

    function createOffsetTab():Void
    {
        offsetUI = new FlxUI(null, uiBox);
        offsetUI.name = "Offsets";

        var animNameTxt = new FlxText(10, 5, 0, "AnimName");
        var animName = new FlxInputText(10, 20, 50);
        offsetUI.add(animNameTxt);
        offsetUI.add(animName);

        var offsetXTxt = new FlxText(70, 5, 0, "OffsetX");
        offsetXInput = new FlxInputText(70, 20, 40);
        offsetUI.add(offsetXTxt);
        offsetUI.add(offsetXInput);

        var offsetYTxt = new FlxText(120, 5, 0, "OffsetY");
        offsetYInput = new FlxInputText(120, 20, 40);
        offsetUI.add(offsetYTxt);
        offsetUI.add(offsetYInput);

        offsetListText = new FlxText(10, 200, 0, "Offsets:\n");
        offsetUI.add(offsetListText);

        var saveButton = new FlxButton(10, 40, "Save Offset", () -> 
        {
            var ox:Float = offsetXInput.text == "" ? 0 : Std.parseFloat(offsetXInput.text);
            var oy:Float = offsetYInput.text == "" ? 0 : Std.parseFloat(offsetYInput.text);

            saveAndRenderOffset(animName.text, [ox, oy]);   
        });

        offsetUI.add(saveButton);
        uiBox.addGroup(offsetUI);
    }

    var exportUI:FlxUI;

    var charInput:FlxInputText;
    var deadCharInput:FlxInputText;
    var flipXCheckbox:FlxUICheckBox;
    var isGFCheckbox:FlxUICheckBox;

    function createExportTab():Void
    {
        exportUI = new FlxUI(null, uiBox);
        exportUI.name = "Export";

        var charTxt:FlxText = new FlxText(10, 10, 0, "Character");
        charInput = new FlxInputText(10, 30, 50);
        exportUI.add(charTxt);
        exportUI.add(charInput);

        var deadCharTxt:FlxText = new FlxText(10, 50, 0, "Dead Char");
        deadCharInput = new FlxInputText(10, 70, 50);
        exportUI.add(deadCharTxt);
        exportUI.add(deadCharInput);

        flipXCheckbox = new FlxUICheckBox(90, 10, null, null, "FlipX");
        exportUI.add(flipXCheckbox);

        isGFCheckbox = new FlxUICheckBox(90, 30, null, null, "Is GF?");
        exportUI.add(isGFCheckbox);

        var exportCharFileBtn = new FlxButton(80, 70, "Export File", exportFile);
        exportUI.add(exportCharFileBtn);

        uiBox.addGroup(exportUI);
    }

    function exportFile():Void
    {
        var charFile:CharacterFile = {
            format: "sparrow",
            character: charInput.text,
            animations: [],
            flipX: flipXCheckbox.checked,
            isGF: isGFCheckbox.checked,
            deathChar: deadCharInput.text == "" ? null : deadCharInput.text
        }

        for (anim in trackedAnims)
        {
            if (charOffset.exists(anim.name))
                anim.offset = charOffset.get(anim.name);
            charFile.animations.push(anim);
        }

        var data:String = Json.stringify(charFile, "\t");

        _file = new FileReference();
        _file.addEventListener(Event.COMPLETE, fileEventThing);
        _file.addEventListener(Event.CANCEL, fileEventThing);
        _file.addEventListener(IOErrorEvent.IO_ERROR, fileEventThing);
        _file.save(data.trim(), '${charFile.character}.json');
    }

    function saveAndRenderOffset(anim:String, off:Array<Float>):Void
    {
        charOffset.set(anim, off);

        offsetListText.text = "Offsets:\n";
        for (key in charOffset.keys())
        {
            var offset:Array<Float> = charOffset.get(key);
            offsetListText.text += '$key | x:${offset[0]}, y:${offset[1]}\n';
        }

        // If the same anim is playing, auto apply offset
        if (char.animation.curAnim != null && char.animation.curAnim.name == anim)
            playAnim(curAnim);
    }

    function playAnim(anim:String, ?force:Bool = false):Void
    {
        var off:Array<Float> = charOffset.get(anim);
        if (off == null)
            off = [0, 0];

        if (basePlayCheckbox.checked)
        {
            base.animation.play(baseAnimInput.text, force);
        }
        else
        {
            char.animation.play(anim, force);
            char.offset.set(off[0], off[1]);
        }
    }

    function addAnim():Void
    {
        if (char == null)
            return;

        var hasIndices:Bool = false;
        if (animIndices.text != "Indices" && animIndices.text != "")
            hasIndices = animIndices.text.split(",").length > 0;

        var meta:AnimationData = 
        {
            name: animNameTxt.text,
            prefix: animPrefixTxt.text,
            fps: Std.int(animFps.value),
            loop: animLoopReal.checked
        }

        if (hasIndices)
        {
            var indices:Array<Int> = [];
            for (strNum in animIndices.text.split(","))
            {
                indices.push(Std.parseInt(strNum));
            }

            meta.indices = indices;

            char.animation.addByIndices(meta.name, meta.prefix, meta.indices, "", meta.fps, animLoop.checked);
            base.animation.addByIndices(meta.name, meta.prefix, meta.indices, "", meta.fps, animLoop.checked);
        }
        else
        {
            char.animation.addByPrefix(meta.name, meta.prefix, meta.fps, animLoop.checked);
            base.animation.addByPrefix(meta.name, meta.prefix, meta.fps, animLoop.checked);
        }

        if (!trackedAnims.contains(meta))
            trackedAnims.push(meta);


        var names:Array<String> = [];
        for (_meta in trackedAnims)
            names.push(_meta.name);

        animsDropdown.setData(FlxUIDropDownMenu.makeStrIdLabelArray(names));

        animListText.text = "Animations:\n";
        for (silly in trackedAnims)
            animListText.text += '${silly.name}\n';
    }

    var lastMsX:Float = 0;
    var lastMsY:Float = 0;

    var canEditOffset:Bool = false;

    override function update(elapsed:Float):Void
    {
        if (!FlxG.mouse.visible)
            FlxG.mouse.visible = true;

        if (FlxG.mouse.wheel != 0)
            FlxG.camera.zoom += (FlxG.mouse.wheel / 10);

        if (FlxG.keys.pressed.SHIFT && FlxG.mouse.pressed)
        {
            var dx:Float = FlxG.mouse.x - lastMsX;
            var dy:Float = FlxG.mouse.y - lastMsY;

            FlxG.camera.scroll.x += -(dx / 2);
            FlxG.camera.scroll.y += -(dy / 2);
        }

        if (FlxG.keys.justPressed.HOME)
            canEditOffset = !canEditOffset;
        canEditTxt.text = '$canEditOffset';

        if (FlxG.keys.justPressed.CONTROL && FlxG.keys.justPressed.Q)
            FlxG.switchState(new TitleState());

        lastMsX = FlxG.mouse.x;
        lastMsY = FlxG.mouse.y;

        // Kills Performance, pls fix
        if (char != null && char.animation != null 
            && char.animation.curAnim != null && canEditOffset)
        {
            var editedOffset:Array<Float> = charOffset.get(char.animation.curAnim.name);
            if (editedOffset == null)
                editedOffset = [0,0];

            if (FlxG.keys.pressed.SHIFT)
            {
                if (FlxG.keys.pressed.UP)
                    editedOffset[1]++;
                if (FlxG.keys.pressed.DOWN)
                    editedOffset[1]--;
                if (FlxG.keys.pressed.LEFT)
                    editedOffset[0]++;
                if (FlxG.keys.pressed.RIGHT)
                    editedOffset[0]--;
            }

            if (FlxG.keys.justPressed.UP)
                editedOffset[1]++;
            if (FlxG.keys.justPressed.DOWN)
                editedOffset[1]--;
            if (FlxG.keys.justPressed.LEFT)
                editedOffset[0]++;
            if (FlxG.keys.justPressed.RIGHT)
                editedOffset[0]--;

            if (FlxG.keys.justPressed.SPACE)
                char.animation.play(char.animation.curAnim.name, true);

            if (offsetTxt != null)
                offsetTxt.text = '${char.animation.curAnim.name}\nx:${editedOffset[0]}\ny:${editedOffset[1]}\n';
            saveAndRenderOffset(char.animation.curAnim.name, editedOffset);
        }

        super.update(elapsed);
    }

    function fileEventThing(_):Void
    {
        _file.removeEventListener(Event.COMPLETE, fileEventThing);
        _file.removeEventListener(Event.CANCEL, fileEventThing);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, fileEventThing);
        _file = null;
    }

    override function destroy():Void
    {
        super.destroy();
        //fileEventThing(null);
        if (uiBox != null)
            uiBox.destroy();
        if (camUI != null)
            camUI.destroy();
        if (base != null)
            base.destroy();
        if (char != null)
            char.destroy();
        if (offsetTxt != null)
            offsetTxt.destroy();
        charOffset.clear();
    }
}
