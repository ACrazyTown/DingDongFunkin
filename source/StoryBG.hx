package;

import donut.load.LoadedAssets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;

typedef StoryBGAssetData = 
{
    ?name:String,
    ?library:String,
    ?animated:Bool,
    ?defaultAnim:String
}

typedef StoryBGAsset =
{
    x:Float,
    y:Float,
    data:StoryBGAssetData
}

typedef StoryBGCollection =
{
    bgColor:FlxColor,
    assets:Array<StoryBGAsset>,
    ?scale:Float
}

class StoryBGSprite extends FlxSprite
{
    public var oldX:Float = 0;
    public var oldY:Float = 0;

    public function new(x:Float = 0, y:Float = 0)
    {
        oldX = x;
        oldY = y;

        super(x, y);
    }
}

class StoryBG extends FlxSpriteGroup
{
    public static final DONUT_SHOP_BG:StoryBGCollection = 
    {
        bgColor: 0xFFBEFFFD,
        assets: 
        [
            {
                x: 140,
                y: 100.5,
                data: {
                    name: "donutShop",
                    library: "donutshop",
                    animated: true,
                    defaultAnim: "donut shop"
                }
            },
            {
                x: -266,
                y: 454,
                data: {
                    name: "stageGround",
                    library: "donutshop"
                }
            },
            {
                x: 38,//-240,
                y: 344,//515,
                data: {
                    name: "appleshopsign",
                    library: "donutshop",
                    animated: true,
                    defaultAnim: "lapis apple shop sign"
                }
            }
        ],
        scale: 0.75
    };

    public static final VOLCANO_BG:StoryBGCollection = 
    {
        bgColor: 0xFFB7D0E8,
        assets:
        [
            {
                x: -27,//-1800,
                y: -88,//-465,
                data: {
                    name: "volcano_Normal",
                    library: "volcano"
                }
            }
        ],
        scale: 0.4
    }

    public var curCollection:StoryBGCollection;

    var bg:FlxSprite;

    public function new(x:Float = 0, y:Float = 0)
    {
        super(x, y);

        // Hardcoded color because lmao
        // Idk why its breaking so im just gona do it like this
        // Maybe will fix in the future if this turns into an engine or something lol
        bg = new FlxSprite(x, y).makeGraphic(FlxG.width, FlxG.height, -1);
        bg.color = 0xFFBEFFFD;
        add(bg);

        var collections:Array<StoryBGCollection> = [DONUT_SHOP_BG, VOLCANO_BG];
        for (collection in collections)
            for (asset in collection.assets)
                LoadedAssets.add(Paths.assetPath(asset.data.name, asset.data.library, IMAGE), null, IMAGE);
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);
    }

    var curMfs:Array<Array<StoryBGSprite>> = [];
    var deadQueue:Array<Array<StoryBGSprite>> = [];
    
    public function swap(daBg:StoryBGCollection):Void
    {
        if (daBg == curCollection)
            return;
        curCollection = daBg;

        var daNew:Array<StoryBGSprite> = [];
        for (asset in daBg.assets)
        {
            var poop:StoryBGSprite = new StoryBGSprite(asset.x, asset.y);
            poop.y += FlxG.height;
            if (asset.data != null) {
                if (asset.data.animated != null && asset.data.animated == true)
                {
                    poop.frames = Paths.getSparrowAtlas(asset.data.name, asset.data.library);
                    poop.animation.addByPrefix("idle", asset.data.defaultAnim, 24, true);
                    poop.animation.play("idle");
                }
                else
                    poop.loadGraphic(Paths.image(asset.data.name, asset.data.library));
            }

            if (daBg.scale != null) {
                poop.scale.set(daBg.scale, daBg.scale);
                poop.updateHitbox();
            }
            poop.alpha = 0;
            add(poop);
            daNew.push(poop);
        }

        // add new ones to everything
        curMfs.insert(0, daNew);

        // skip 0 because 0 is the new ones
        for (i in 1...curMfs.length) 
        {
            var balls:Array<StoryBGSprite> = curMfs[i];
            for (i in 0...balls.length)
            {
                var baller:StoryBGSprite = balls[i];

                if (baller != null)
                    FlxTween.cancelTweensOf(baller); // get rid of pending shit cuz we gonna

                FlxTween.tween(baller, {y: baller.oldY + FlxG.height, alpha: 0}, 0.9, {ease: FlxEase.expoInOut, startDelay: 0.2 * i, onComplete: (t:FlxTween) -> 
                {
                    remove(baller);
                    baller.destroy();
                    balls.remove(baller);
                }});
            }
        }

        FlxTween.cancelTweensOf(bg);
        FlxTween.color(bg, 1, bg.color, daBg.bgColor);
        for (i in 0...daNew.length)
        {
            var o:StoryBGSprite = daNew[i];
            if (o != null)
                FlxTween.tween(o, {y: o.oldY, alpha: 1}, 0.9, {ease: FlxEase.expoInOut, startDelay: 0.2 * i});
        }
    }
}