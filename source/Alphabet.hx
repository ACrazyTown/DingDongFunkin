/*package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;

using StringTools;

This needs a rework, IDC LOL
class Alphabet extends FlxSpriteGroup
{
	private var startX:Float = 0;
	private var startY:Float = 0;

	public var text(default, set):String;
	public var bold:Bool = true;

	public var isMenuItem:Bool = false;

	public var forceX:Float = Math.NEGATIVE_INFINITY;
	public var targetY:Int = 0;

	public var xAdd:Float = 0;
	public var yAdd:Float = 0;
	public var yMult:Float = 120;

	private var characters:Array<AlphabetCharacter> = [];

	public function new(x:Float = 0, y:Float = 0, text:String = "", ?bold:Bool = true)
	{
		startX = x;
		startY = y;

		super(x, y);

		this.bold = bold;
		this.text = text;
	}

	private var lastChar:AlphabetCharacter;
	public var lineBreaks:Int = 0;

	public function drawText(text:String):Void
	{
		var xPos:Float = 0;
		var yPos:Float = 0;
		var spaces:Int = 0;

		for (char in text.split(""))
		{
			if (lastChar != null) 
			{
				xPos = (lastChar.x + lastChar.width);
				if (spaces > 0)
					xPos += spaces * 40;
				spaces = 0;
			}
				
			switch (char.fastCodeAt(0))
			{
				case 32://space
					spaces++;
					continue;
				
				case 10: // newline
					lineBreaks++;
					xPos = 0;
					yPos = 85 * lineBreaks;
					lastChar = null;
					continue;
			}

			var charSprite:AlphabetCharacter = new AlphabetCharacter(xPos, yPos);
			charSprite.drawCharacter(char, this.bold);
			charSprite.x += charSprite.letterOffset[0];
			charSprite.y -= charSprite.letterOffset[1];
			add(charSprite);

			characters.push(charSprite);
			lastChar = charSprite;
		}
	}

	public function reType(text:String):Void
	{
		if (characters != null)
		{
			for (char in characters)
			{
				if (char != null)
				{
					char.kill();
					remove(char, true);
					char.destroy();
				}
			}
		}

		if (lastChar != null)
			lastChar.destroy();

		updateHitbox();

		x = startX;
		y = startY;

		drawText(text);
	}

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 9.6, 0, 1);
			y = FlxMath.lerp(y, (scaledY * yMult) + (FlxG.height * 0.48) + yAdd, lerpVal);
			if (forceX != Math.NEGATIVE_INFINITY) 
				x = forceX;
			else 
				x = FlxMath.lerp(x, (targetY >= 0 ? targetY * -40 : targetY * 40) + 90 + xAdd, lerpVal); // targetY * 20
		}

		super.update(elapsed);
	}

	override function destroy():Void
	{
		for (char in characters)
		{
			if (char != null)
				char.destroy();
		}

		if (lastChar != null)
			lastChar.destroy();

		super.destroy();
	}

	function set_text(value:String):String 
	{
		reType(value);
		this.text = value;
		return value;
	}
}

// I know I could've used FlxPoint but I think it wastes memory a bit.

typedef AlphaCharData =
{
	?offsets:Array<Float>,
	?offsetsBold:Array<Float>
}

class AlphabetCharacter extends FlxSprite
{
	public static var ALPHABET:String = "abcdefghijklmnopqrstuvwxyz";
	public static var NUMBERS:String = "1234567890";
	public static var SYMBOLS:String = "&()*+-<>'\"!?._#$%:;@[]^,\\/|~";

	private var charData:Map<String, AlphaCharData> = [ // FROM PSYCH ENGINE I LOVE PSYCH ENGINE
		//alphabet
		
		//numbers
		'0'  => null, '1'  => null, '2'  => null, '3'  => null, '4'  => null,
		'5'  => null, '6'  => null, '7'  => null, '8'  => null, '9'  => null,

		//symbols
		'&'  => {offsetsBold: [0, 2]},
		'('  => {offsetsBold: [0, 5]},
		')'  => {offsetsBold: [0, 5]},
		'*'  => {offsets: [0, 28]},
		'+'  => {offsets: [0, 7], offsetsBold: [0, -12]},
		'-'  => {offsets: [0, 16], offsetsBold: [0, -30]},
		'<'  => {offsetsBold: [0, 4]},
		'>'  => {offsetsBold: [0, 4]},
		'\'' => {offsets: [0, 32]},
		'"'  => {offsets: [0, 32], offsetsBold: [0, 0]},
		'!'  => {offsetsBold: [0, 10]},
		'?'  => {offsetsBold: [0, 4]},			//also used for "unknown"
		'.'  => {offsetsBold: [0, -44]},
		'❝'  => {offsets: [0, 24], offsetsBold: [0, -5]},
		'❞'  => {offsets: [0, 24], offsetsBold: [0, -5]},

		//symbols with no bold
		'_'  => null,
		'#'  => null,
		'$'  => null,
		'%'  => null,
		':'  => {offsets: [0, 2]},
		';'  => {offsets: [0, -2]},
		'@'  => null,
		'['  => null,
		']'  => {offsets: [0, -1]},
		'^'  => {offsets: [0, 28]},
		','  => {offsets: [0, -6]},
		'\\' => {offsets: [0, 0]},
		'/'  => {offsets: [0, 0]},
		'|'  => null,
		'~'  => {offsets: [0, 16]}
	];

	public var letterOffset:Array<Float> = [0, 0];

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		frames = Paths.getSparrowAtlas("alphabet");
	}

	public function drawCharacter(char:String, ?bold:Bool = true):Void
	{
		var lChar:String = char.toLowerCase();
		var charCase:String = (char.toUpperCase() == char) ? "uppercase" : "lowercase";

		if (ALPHABET.contains(lChar) || SYMBOLS.contains(lChar) || NUMBERS.contains(lChar))
		{
			var char:String = formatCharacter(lChar);
			var animName:String = "";

			if (bold)
				animName = '$char bold';
			else
				animName = ALPHABET.contains(lChar) ? '$char $charCase' : '$char normal';

			animation.addByPrefix(animName, animName, 24);
			animation.play(animName);
		}

		var data:AlphaCharData = charData.get(lChar);
		if (data != null)
		{
			var _offset:Array<Float> = bold ? data.offsetsBold : data.offsets;
			if (_offset == null)
				_offset = [0, 0];

			//trace(_offset);

			letterOffset[0] = _offset[0];
			letterOffset[1] = _offset[1];
		}

		updateHitbox();
		if (animation.curAnim != null && !animation.curAnim.name.endsWith('bold'))
			offset.y += -(110 - height);

	}

	private function formatCharacter(char:String):String
	{
		return switch (char)
		{
			case ".": "period";
			case "'": "apostrophe";
			case "?": "question";
			case "\"": "quote";
			case "!": "exclamation";
			case "/": "forward slash";
			case "\\": "backslash";
			case ",": "comma";
			default: char;
		}
	}
}
*/

package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;

using StringTools;

class Alphabet extends FlxSpriteGroup
{
	private var startX:Float = 0;
	private var startY:Float = 0;

	public var text:String;
	public var bold:Bool = true;

	public var isMenuItem:Bool = false;

	public var forceX:Float = Math.NEGATIVE_INFINITY;
	public var targetY:Int = 0;

	public var xAdd:Float = 0;
	public var yAdd:Float = 0;
	public var yMult:Float = 120;

	private var characters:Array<AlphabetCharacter> = [];

	public function new(x:Float = 0, y:Float = 0, text:String = "", ?bold:Bool = true)
	{
		startX = x;
		startY = y;

		super(x, y);

		this.bold = bold;
		this.text = text;

		drawText();
	}

	private var lastChar:AlphabetCharacter;
	private var spaceChar:Bool = false;

	public function drawText():Void
	{
		var xPos:Float = 0;
		var individualChars:Array<String> = text.split("");
		for (char in individualChars)
		{
			if (char == " ")
				spaceChar = true;

			if (AlphabetCharacter.ALPHABET.contains(char.toLowerCase()) 
				|| AlphabetCharacter.SYMBOLS.contains(char.toLowerCase()) 
				|| AlphabetCharacter.NUMBERS.contains(char.toLowerCase()))
			{
				if (lastChar != null)
					xPos = (lastChar.x + lastChar.width);

				if (spaceChar)
				{
					xPos += 40;
					spaceChar = false;
				}

				var charSprite:AlphabetCharacter = new AlphabetCharacter(xPos, 0);
				charSprite.drawCharacter(char, this.bold);
				add(charSprite);

				characters.push(charSprite);
				lastChar = charSprite;
			}
		}
	}

	public function reType(text:String):Void
	{
		for (char in characters)
		{
			if (char != null)
			{
				remove(char);
				char.destroy();
			}
		}

		if (lastChar != null)
			lastChar.destroy();
		lastChar = null;

		updateHitbox();

		x = startX;
		y = startY;

		this.text = text;
		drawText();
	}

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 9.6, 0, 1);
			y = FlxMath.lerp(y, (scaledY * yMult) + (FlxG.height * 0.48) + yAdd, lerpVal);
			if (forceX != Math.NEGATIVE_INFINITY)
				x = forceX;
			else 
				x = FlxMath.lerp(x, (targetY >= 0 ? targetY * -40 : targetY * 40) + 90 + xAdd, lerpVal); // targetY * 20
		}

		super.update(elapsed);
	}

	override function destroy():Void
	{
		for (char in characters)
		{
			if (char != null)
				char.destroy();
		}

		if (lastChar != null)
			lastChar.destroy();

		super.destroy();
	}
}

// I know I could've used FlxPoint but I think it wastes memory a bit.
typedef Offset = 
{
	x:Float,
	y:Float
}

typedef AlphaCharData =
{
	?offset:Offset,
	?offsetBold:Offset
}

class AlphabetCharacter extends FlxSprite
{
	public static var ALPHABET:String = "abcdefghijklmnopqrstuvwxyz";
	public static var NUMBERS:String = "1234567890";
	public static var SYMBOLS:String = "|~#$%()*+-:;<=>@[]^_.,'!?";

	private var charData:Map<String, AlphaCharData> = [
		"a" => {offset: {x: 0, y: 3}}, "b" => {offset: {x: 0, y: 18}}, "d" => {offset: {x: 0, y: 20}},
		"l" => {offset: {x: 0, y: 10}}, "t" => {offset: {x: 0, y: 14}}, "h" => {offset: {x: 0, y: 15}},
		"m" => {offset: {x: 0, y: -5}}, "r" => {offset: {x: 0, y: -5}}, "y" => {offset: {x: 0, y: -3}},
		"i" => {offset: {x: 0, y: 8}}, "k" => {offset: {x: 0, y: 10}}, "j" => {offset: {x: 0, y: 5}},
		"u" => {offset: {x: 0, y: -3}}, "f" => {offset: {x: 0, y: 8}}, "n" => {offset: {x: 0, y: -8}},

		"?" => {offset: {x: 0, y: -50}},

		"8" => {offset: {x: 0, y: 10}}, "9" => {offset: {x: 0, y: 10}}
	];

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		frames = Paths.getSparrowAtlas("alphabet");
	}

	public function drawCharacter(char:String, ?bold:Bool = true):Void
	{
		var lChar:String = char.toLowerCase();
		var charCase:String = (char.toUpperCase() == char) ? "capital" : "lowercase";

		if (ALPHABET.contains(lChar))
		{
			if (!bold)
			{
				animation.addByPrefix(lChar, '${(charCase == "capital") ? char.toUpperCase() : char.toLowerCase()} $charCase', 24);
				animation.play(lChar);
			}
			else
			{
				animation.addByPrefix(lChar, '${char.toUpperCase()} bold', 24);
				animation.play(lChar);
			}
		}

		if (SYMBOLS.contains(lChar))
		{
			var animName:String = formatCharacter(lChar, bold);
			animation.addByPrefix(lChar, animName, 24);
			animation.play(lChar);
		}

		if (NUMBERS.contains(lChar))
		{
			animation.addByPrefix(lChar, lChar, 24);
			animation.play(lChar);
		}

		updateHitbox();

		var d:AlphaCharData = charData.get(char);
		if (d != null)
		{
			var daOffset:Offset = bold ? d.offsetBold : d.offset;
			if (daOffset != null)
				offset.set(daOffset.x, daOffset.y);
		}
		else
		{
			if (charCase == "capital" && !bold)
				offset.y = height / 2.7;
		}
	}

	/**
	 * bold check is temporary; i do not want to remake Alphabet now
	 * eventually if i turn this into a engine it will be remade lol
	 */
	private function formatCharacter(char:String, ?bold:Bool = true):String
	{
		return switch (char)
		{
			case ".": "period";
			case "'": "apostraphie";
			case "?": bold ? "QUESTION MARK bold" : "question mark";
			case "!": "exclamation point";
			case " ": "space";
			default: "question mark";
		}
	}
}