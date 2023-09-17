package;

import flixel.FlxSprite;
import openfl.Assets as OpenFlAssets;

using StringTools;

class HealthIcon extends TrackedSprite
{
	private var character:String = "";
	var isPlayer:Bool = false;

	public function new(char:String = "bf", isPlayer:Bool = false):Void
	{
		super();
		
		this.isPlayer = isPlayer;

		changeIcon(char);
		scrollFactor.set();

		xOffset = 10;
		yOffset = 30;
	}

	public function changeIcon(newChar:String):Void
	{
		if (newChar != character)
		{
			if (animation.getByName(newChar) == null)
			{
				loadGraphic(findIcon(newChar), true, 150, 150);
				animation.add(newChar, [0, 1], 0, false, isPlayer);
			}
			
			animation.play(newChar);
			character = newChar;
		}
	}

	function findIcon(char:String)
	{
		var img = Paths.assetPath('icons/icon-${char}', null, IMAGE);
		if (!OpenFlAssets.exists(img))
		{
			img = Paths.assetPath('icons/icon-${char.split('-')[0].trim()}', null, IMAGE);

			if (!OpenFlAssets.exists(img))
				img = Paths.assetPath('icons/icon-face', null, IMAGE);
		}
		return img;
	}
}
