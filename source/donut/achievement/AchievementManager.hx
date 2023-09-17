package donut.achievement;

import flixel.math.FlxPoint;
import openfl.events.TimerEvent;
import openfl.utils.Timer;
import motion.easing.Quad;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import openfl.display.Sprite;
import motion.Actuate;
import openfl.Lib;

// based off indie cross gjtoastmanager!!!
// https://github.com/brightfyregit/Indie-Cross-Public/blob/master/source/GameJolt.hx
class AchievementManager extends Sprite
{
    var sound:FlxSound;

    public function new()
    {
        super();

        FlxG.signals.gameResized.add(onResize);

        sound = new FlxSound().loadEmbedded(Paths.sound("achievementUnlock", "preload"));
        //sound.volume = 0.6;
        sound.persist = true;

        FlxG.sound.list.add(sound);
    }

    private function onResize(w:Int, h:Int):Void
    {
        //trace(FlxG.scaleMode.gameSize);

        for (child in __children)
        {
            if (child != null)
            {
                /*
                var size:FlxPoint = FlxG.scaleMode.gameSize;

                child.scaleX = size.x / FlxG.width;
                child.scaleY = size.y / FlxG.height;

                var singleBarSize:Float = ((FlxG.stage.window.width - size.x) / 2);
                child.x = (FlxG.stage.window.width - singleBarSize) - (child.scaleX * AchievementSprite._width);

                //Actuate.stop(child);
                //child.y = Main.instance.game.y;
                */

                child.visible = false;
                removeChild(child);
            }
        }
    }

    public function trigger(id:String):Void
    {
        if (!AchievementData.achievements.exists(id) || AchievementData.isUnlocked(id) 
            || FlxG.save.data.cheatedUnlock)
            return;

        AchievementData.unlock(id);

        var trueSize:FlxPoint = FlxG.scaleMode.gameSize;

        var spr:AchievementSprite = new AchievementSprite();
        spr.x = Lib.current.stage.stageWidth - AchievementSprite._width;
        if (FlxG.stage.stageWidth != FlxG.width || FlxG.stage.stageHeight != FlxG.height)
        {
            // RESIZING TYPE BEAT!!!
            var size:FlxPoint = FlxG.scaleMode.gameSize;

            spr.scaleX = size.x / FlxG.width;
            spr.scaleY = size.y / FlxG.height;

            var singleBarSize:Float = ((FlxG.stage.window.width - size.x) / 2);
            spr.x = (FlxG.stage.window.width - singleBarSize) - (spr.scaleX * AchievementSprite._width);
        }
        //spr.y = Main.instance.game.y - (spr.scaleY * AchievementSprite._height);
        spr.y = -Lib.current.stage.height - (spr.scaleY * AchievementSprite._height);

        addChild(spr);

        sound.play(true);

        var oldY:Float = spr.y;
        var coolY:Float = Main.instance.game.y;

        Actuate.tween(spr, 0.75, {y: coolY}).ease(Quad.easeInOut).onComplete(() -> 
        {
            var swagTimer:Timer = new Timer(5000, 1);
            swagTimer.addEventListener(TimerEvent.TIMER_COMPLETE, (e:TimerEvent) -> 
            {
                Actuate.tween(spr, 0.75, {y: oldY}).ease(Quad.easeInOut).onComplete(()->
                {
                    spr.removeChildren();
                    removeChild(spr);
                });
            });
            swagTimer.start();
        });
    }
}
