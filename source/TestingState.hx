package;

import openfl.Lib;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.addons.display.FlxGridOverlay;
import flixel.util.FlxColor;

class TestingState extends MusicBeatState
{
    var goof:FlxText;
    public static var GREEne:Bool = false;

    override function create():Void
    {
        if (!GREEne)
        {
            FlxG.mouse.visible = true;

            add(FlxGridOverlay.create(10, 10, FlxG.width, FlxG.height));

            //boy = new FlxAnimate(0, 0, "assets/atlases/abundance_woo", {Antialiasing: true});
            //boy.anim.addBySymbol("test", "BF WOOO", 0, 0, 24);
            //boy.screenCenter();
            //boy.updateHitbox();
            //add(boy);
            trace("add BOYE");

            ///boy.playAnim("test");
            //"reg query HKCU\\Control Panel\\Desktop /v WallPaper"
            var p = new sys.io.Process("echo off && for /f \"tokens=3\" %a in ('REG QUERY \"HKCU\\Control Panel\\Desktop\" /v WallPaper') do echo %a");
            var path = "";
            path = p.stdout.readAll().toString();
            p.close();
            //Paths.setCurrentLevel("shared");
            FlxG.sound.playMusic(Paths.music("tension"));

            goof = new FlxText(10, 10, 0, "1.0", 24);
            goof.setBorderStyle(OUTLINE, FlxColor.BLACK, 4);
            add(goof);
        }
        else
        {
            add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(0, 255, 0)));
        }

        super.create();
    }

    var gay:Array<String> = [
        "micah:It's really not fair you know.",
        "bf:Bep?",
        "micah:This is NOT fair.",
        "micah:Argh.",
        "micah:I was the one who's really allergic to nuts.",
        "micah:Not that... stupid, mainstream, little [UHOH!]",
        "bf:Boop.",
        "micah:They don't care that I'm the original.",
        "micah:They care for the POPULAR characters.",
        "micah:They care for the one with 'more worth'.",
        "micah:Doesn't even help that everyone else got fancy 'video' and 'in-game' cutscenes, and I'm here with the STUPID old dialogue.",
        "bf:...beep?",
        "micah:ARRGH!! FINE then.",
        "micah:I can't do anything to them... but I can do everything to you.",
        "micah:You're in my territory now.",
        "micah:Good luck, because you're about to be FUNKED."
    ];

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.H)
        {
            FlxG.mouse.visible = false;
            GREEne = true;
            //(cast (Lib.current.getChildAt(0), Main)).toggleFPS(false);
            FlxG.resetState();
        }

        if (FlxG.keys.justPressed.G && !GREEne)
        {
            FlxG.sound.music.stop();

            super.openSubState(new DialogueSubstate(gay, "tension", "null"));
        }

        if (FlxG.keys.justPressed.L)
        {
            FlxG.sound.music.stop();
            //super.openSubState(new donut.DingTransition());
        }
    }
}
