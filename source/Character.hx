package;

import flixel.graphics.frames.FlxFramesCollection;
import flixel.util.FlxColor;
import haxe.Json;
import openfl.Assets;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxSprite;

using StringTools;

typedef AnimationData =
{
    name:String,
    prefix:String,
    fps:Int,
    loop:Bool,
    ?indices:Array<Int>,
    ?offset:Array<Float>
}

typedef CharacterFile =
{
    format:String,
    character:String,
    animations:Array<AnimationData>,
    flipX:Bool,
    isGF:Bool,
    ?deathChar:String,
    ?color:String
}

/**
  Made by A Crazy Town for Ding Mod 2.0/DONUT Engine
**/
// mess, bozo!
class Character extends FlxSprite
{
    public var animationOffsets:Map<String, Array<Float>> = [];

    public var character:String = "bf";
    public var deathCharacter:String = "bf-dead";

    public var accentColor:FlxColor;

    public var isPlayer:Bool = false;
    public var holdTimer:Float = 0;

    private var data:CharacterFile;

    public function new(x:Float = 0, y:Float = 0, character:String = "bf", ?isPlayer:Bool = false, ?atlases:Array<FlxFramesCollection>):Void
    {
        super(x, y);

        this.character = character;
        this.isPlayer = isPlayer;

        data = Json.parse(Assets.getText(Paths.char(character)));
        
        var characterPath:String = 'characters/$character';
        var tex:FlxAtlasFrames = null;
        try {
            tex = Paths.getSparrowAtlas('$characterPath/$character', "shared");
        } catch (e:haxe.Exception) {
            FlxG.log.error("Failed to load character: " + character);
            tex = Paths.getSparrowAtlas('characters/dad/dad', "shared"); // rely on daddy :3
        }

        frames = CoolUtil.combineFrames(tex, atlases);

        for (anim in data.animations)
        {
            var offsets:Array<Float> = anim.offset;

            if (offsets != null)
            {
                while (offsets.length < 2)
                    offsets.push(0);
            }
            else
                offsets = [0, 0];
            
            if (anim.indices == null || anim.indices.length <= 0)
                animation.addByPrefix(anim.name, anim.prefix, anim.fps, anim.loop);
            else
                animation.addByIndices(anim.name, anim.prefix, anim.indices, "", anim.fps, anim.loop);

            addOffset(anim.name, offsets[0], offsets[1]);
        }

        // name prefix fps loop flipxy
        flipX = data.flipX;
        deathCharacter = data.deathChar;
        accentColor = (data.color == null) ? 0xFFA6CCE8 : FlxColor.fromString(data.color);

        if (data.isGF && animation.exists("danceLeft")) // check if gf
            playAnim("danceLeft");
        else if (animation.exists("idle")) // fallback for most other anims?
            playAnim("idle");

        animation.finish();
        // do nothing?
    }

    private var danced:Bool = false;
    override function update(elapsed:Float):Void
    {
        if (animation.curAnim != null)
        {
            if (!character.startsWith('bf'))
            {
                if (animation.curAnim.name.startsWith('sing'))
                    holdTimer += elapsed;

                var dadVar:Float = 4;
                if (character == 'dad')
                    dadVar = 6.1;

                if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
                {
                    dance();
                    holdTimer = 0;
                }
            }

            switch (character)
            {
                case 'gf':
                    if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
                        playAnim('danceRight');
            }
        }

        super.update(elapsed);
    }

    override function destroy():Void
    {
        animationOffsets = null;
        data = null;

        super.destroy();
    }

    public function dance(?force:Bool = false)
    {
        if (data.isGF)
        {
            if (animation.curAnim != null && !animation.curAnim.name.startsWith('hair'))
            {
                danced = !danced;
                playAnim('dance${danced ? "Right" : "Left"}', force);
            }
        }
        else
            playAnim("idle", force);
    }

    public function playAnim(Animation:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
    {
        animation.play(Animation, Force, Reversed, Frame);

        var currentOffset:Array<Float> = [0, 0];

        if (animationOffsets.exists(Animation))
            currentOffset = animationOffsets.get(Animation);
        else
            animationOffsets.set(Animation, [0, 0]); // No offset found, let's make one

        offset.set(currentOffset[0], currentOffset[1]);

        if (data.isGF) // if char gf mode ?
        {
            if (Animation == 'singLEFT')
                danced = true;
            if (Animation == 'singRIGHT')
                danced = false;
            if (Animation == 'singUP' || Animation == 'singDOWN')
                danced = !danced;
        }
    }

    public function addOffset(name:String, x:Float = 0, y:Float = 0):Void
    {
        animationOffsets.set(name, [x, y]);
    }

    public function addAtlas(atlas:FlxAtlasFrames, reload:Bool = false):Void
    {
        if (this.frames == null || atlas == null || atlas.frames == null) 
            return;

        var collection:FlxFramesCollection = this.frames;
        
        for (frame in atlas.frames)
        {
            if (frame != null)
                collection.pushFrame(frame);
        }

        this.frames = collection;
    }
}
