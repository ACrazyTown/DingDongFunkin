package;

import flixel.util.FlxTimer;
import flixel.addons.text.FlxTypeText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;

class DialogueSubstate extends MusicBeatSubstate
{
    // back backend shit
    public static var instance:DialogueSubstate = null;
    public static var onFinish:Void->Void = null;

    private var dialogue:Array<String> = null;
    private var song:String = null;
    
    // backend shit
    private var texts:Array<String> = null;
    private var chars:Array<String> = null;
    private var expressions:Array<String> = null;

    // frontend shit
    private var music:FlxSound = null;
    public var overlay:FlxSprite = null;
    public var dialogueBox:FlxSprite = null;
    public var portrait:FlxSprite = null;
    public var typeText:FlxTypeText = null;

    private var canStart:Bool = false;
    private var started:Bool = false;
    private var ended:Bool = false;

    public function new(dialogue:Array<String>, ?bgMusic:String, ?song:String)
    {
        instance = this;

        super();
        
        this.dialogue = dialogue;
        this.song = (song == null) ? PlayState.SONG.song : song;
        
        parseDialogueData(dialogue);

        music = new FlxSound().loadEmbedded(Paths.music(bgMusic), true);
        music.play();
        music.fadeIn(1, 0, 0.7);

        overlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        overlay.alpha = 0;
        add(overlay);

        FlxTween.tween(overlay, {alpha: 0.7}, 0.8, {onComplete: (t:FlxTween) -> 
        {
            dialogueBox = new FlxSprite(100, 370);
            dialogueBox.frames = Paths.getSparrowAtlas("dialogueBox");
            dialogueBox.animation.addByPrefix("normal", "speech bubble normal", 24);
		    dialogueBox.animation.addByPrefix("normalOpen", "Speech Bubble Normal Open", 24, false);
            dialogueBox.scrollFactor.set();
            dialogueBox.setGraphicSize(Std.int(dialogueBox.width * 0.9));
            dialogueBox.updateHitbox();
            dialogueBox.animation.play("normalOpen");
            add(dialogueBox);

            typeText = new FlxTypeText(175, 470, Std.int(FlxG.width * 0.6), "", 32);
            typeText.color = FlxColor.BLACK;
            typeText.font = "Comic Sans MS";
            typeText.sounds = [FlxG.sound.load(Paths.sound("pixelText"), 0.6)];
            add(typeText);

            canStart = true;
        }});
    }

    override function update(elapsed:Float):Void
    {
        if (dialogueBox != null && dialogueBox.animation.curAnim != null)
        {
            if (dialogueBox.animation.curAnim.name == "normalOpen" 
                && dialogueBox.animation.curAnim.finished)
                dialogueBox.animation.play("normal");
        }

        if (canStart && !started)
        {
            refreshDialogue();
            started = true;
        }

        if (FlxG.keys.justPressed.ENTER && started && !ended)
        {
            FlxG.sound.play(Paths.sound("clickText"), 0.8);

            // dont bother with the rest as the text is the most important
            if (texts.length <= 1 && !ended)
            {
                ended = true;

                music.fadeOut(1.8, 0);
                FlxTween.tween(typeText, {alpha: 0}, 1.4);
                FlxTween.tween(dialogueBox, {alpha: 0}, 1.4);
                FlxTween.tween(overlay, {alpha: 0}, 1.8, {onComplete: (t:FlxTween) ->
                {
                    if (onFinish != null)
                        onFinish();
                    close();
                }});
            }
            else
            {
                refreshDialogueData();
                refreshDialogue();
            }
        }

        super.update(elapsed);
    }

    private function refreshDialogue():Void
    {
        if (chars[0] != null && chars[0] != "bf")
            dialogueBox.flipX = true;
        else
            dialogueBox.flipX = false;

        typeText.resetText(texts[0]);
        typeText.start(0.04, true);
    }

    private function parseDialogueData(input:Array<String>):Void
    {
        texts = [];
        chars = [];
        expressions = [];

        for (i in 0...input.length)
        {
            var processedData:Array<String> = input[i].split(":");

            // full length?
            if (processedData.length >= 3)
            {
                chars.push(processedData[0]);
                expressions.push(processedData[1]);
                texts.push(processedData[2]);
            }
            else // missing expression?
            {
                chars.push(processedData[0]);
                texts.push(processedData[1]);
            }
        }
    }

    private function refreshDialogueData():Void
    {
        texts.shift();
        chars.shift();
        expressions.shift();
    }
}
