package;

import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxMath;
import flixel.FlxSprite;

using StringTools;

class NoteSkin
{
	public static var NORMAL:String = "normal";
	public static var DING:String = "ding";
	public static var DONUT:String = "donut";

	inline public static function pathFromId(id:String):String
	{
		return switch (id.toLowerCase())
		{
			case "normal": "NOTE_assets";
			case "ding": "DING_NOTE_assets";
			case "donut": "DING_finaldonutArrows";
			default: "DING_NOTE_assets";
		}
	}
}

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var rawNoteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType:Int = 0;

	private var willMiss:Bool = false;

	public var offsetY:Float = 0;

	public static var swagWidth:Float = 160 * 0.7;

	public var rating:String = "shit";

	private var earlyHitMult:Float = 0.5;

	public var isParent:Bool = false;
	public var parent:Note = null;
	public var spotInLine:Int = 0;
	public var sustainActive:Bool = true;

	public var colors:Array<String> = ["purple", "blue", "green", "red"];
	public static var directions:Array<String> = ["left", "down", "up", "right"];

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?noteType:Int = 0, ?inCharter:Bool = false)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.noteType = noteType;
		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += 50;
		y -= 2000; // MAKE SURE ITS DEFINITELY OFF SCREEN?

		this.strumTime = inCharter ? strumTime : Math.round(strumTime);
		if (this.strumTime < 0)
			this.strumTime = 0;

		this.noteData = noteData;

		loadAnims();

		x += swagWidth * noteData;
		animation.play(colors[noteData] + "Scroll");

		// trace(prevNote);

		// we make sure its downscroll and its a SUSTAIN NOTE (aka a trail, not a note)
		// and flip it so it doesn't look weird.
		// THIS DOESN'T FUCKING FLIP THE NOTE, CONTRIBUTERS DON'T JUST COMMENT THIS OUT JESUS
		if (FlxG.save.data.downscroll && isSustainNote) 
			flipY = true;

		var stepHeight = (0.45 * Conductor.stepCrochet * FlxMath.roundDecimal(PlayState.instance.scrollSpeed, 2));
		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;

			x += width / 2;
			animation.play(colors[noteData] + "holdend");

			updateHitbox();
			x -= width / 2;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(colors[prevNote.noteData] + "hold");
				prevNote.updateHitbox();
			
				prevNote.scale.y *= (stepHeight+2) / prevNote.height;
				prevNote.updateHitbox();
				prevNote.offsetY = Math.round(-prevNote.offset.y);

				offsetY = Math.round(-offset.y);
				// prevNote.setGraphicSize();
			}
		}
	}

	public function resizeSustain(val:Float):Void
	{
		if (isSustainNote && animation.curAnim != null && !animation.curAnim.name.endsWith("end"))
		{
			scale.y *= val;
			updateHitbox();
		}
	}

	function loadAnims(?noteStyle:String):Void
	{
		var skin:String = NoteSkin.DING;
		if (PlayState.SONG != null && PlayState.SONG.noteStyle != null)
			skin = PlayState.SONG.noteStyle;
		else if (noteStyle != null)
			skin = noteStyle;

		var secondary:Array<FlxFramesCollection> = (noteType == 2) ? [Paths.getSparrowAtlas(NoteSkin.pathFromId(NoteSkin.DONUT), "shared")] : [];
		frames = CoolUtil.combineFrames(Paths.getSparrowAtlas(NoteSkin.pathFromId(skin), "shared"), secondary);
		
		var scrollAnimName:String = (noteType == 2) ? '${directions[noteData]} Donut' : '${colors[noteData]}0';
		animation.addByPrefix('${colors[noteData]}Scroll', scrollAnimName);

		if (isSustainNote)
		{
			//trace(colors[noteData]);
			animation.addByPrefix('purpleholdend', 'pruple end hold');
			animation.addByPrefix('${colors[noteData]}hold', '${colors[noteData]} hold piece');
			animation.addByPrefix('${colors[noteData]}holdend', '${colors[noteData]} hold end');
		}

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
	}

	override function destroy():Void 
	{
		prevNote = null;
		rating = null;
		parent = null;
		colors = null;
		super.destroy();
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (mustPress)
		{
			// Miss on the NEXT frame so lag doesn't make u miss notes.
			if (willMiss && !wasGoodHit)
			{
				tooLate = true;
				canBeHit = false;
			}
			else
			{
				if (noteType != 2)
				{
					if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset 
						&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
						canBeHit = true;
				}
				else // DONUT notes harder to hit Lol
				{
					if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 0.6)
						&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.4))
						canBeHit = true;
				}
				
				
				if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
					willMiss = canBeHit = true;
			}
		}
		else
		{
			canBeHit = false;

			if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
				if ((isSustainNote && prevNote.wasGoodHit) || strumTime <= Conductor.songPosition)
					wasGoodHit = true;
		}

		if (tooLate && alpha > 0.3)
			alpha = 0.3;
	}
}
