package;

using StringTools;

class Boyfriend extends Character
{
	public static var specialAnims:Array<String> = [
		"hey",
		"hit",
		"dodge"
	];

	public var stunned:Bool = false;

	public function new(x:Float, y:Float, ?char:String = 'bf', ?additionalAtlases:Array<flixel.graphics.frames.FlxFramesCollection>)
	{
		//super(0, 0, "", "", true);
		super(x, y, char, true, additionalAtlases);
	}

	override function update(elapsed:Float):Void
	{
		if (animation.curAnim != null)
		{
			if (animation.curAnim.name.startsWith('sing'))
				holdTimer += elapsed;
			else
				holdTimer = 0;

			if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished)
				playAnim('idle', true, false, 10);

			//if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished)
			//	playAnim('deathLoop');
		}
		
		super.update(elapsed);
	}
}
