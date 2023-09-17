package;

import Note.NoteSkin;
import flixel.FlxSprite;

class StrumNote extends FlxSprite
{
    public var ogX:Float = 0;
    public var ogY:Float = 0;

    public var noteData:Int = 0;

    var player:Int = 0;

    public function new(x:Float, y:Float, noteData:Int, player:Int)
    {
        ogX = x;
        ogY = y;

        super(x, y);

        this.noteData = noteData;
        this.player = player;

        loadAnims();
        scrollFactor.set();
    }

    function loadAnims():Void
    {
        var skin:String = NoteSkin.DING;
		if (PlayState.SONG != null && PlayState.SONG.noteStyle != null)
			skin = PlayState.SONG.noteStyle;

		frames = Paths.getSparrowAtlas(NoteSkin.pathFromId(skin));
		
        var direction:String = Note.directions[noteData];

        animation.addByPrefix('static', 'arrow${direction.toUpperCase()}');
        animation.addByPrefix('pressed', '${direction.toLowerCase()} press', 24, false);
        animation.addByPrefix('confirm', '${direction.toLowerCase()} confirm', 24, false);

        setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
    }

    public function playAnim(name:String, ?force:Bool = true):Void
    {
        animation.play(name, force);
        centerOffsets();
        centerOrigin();

        if (animation.curAnim != null && animation.curAnim.name == "confirm") // ???
            centerOrigin();
    }

    public function postAdd():Void
    {
        playAnim("static");
		//x += Note.swagWidth * noteData;
		//x += 50;
		x += (Note.swagWidth * noteData) + 50 + ((FlxG.width / 2) * player);
		ID = noteData;

        ogX = x;
    }
}