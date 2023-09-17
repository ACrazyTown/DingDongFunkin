package;

import Alphabet.AlphabetCharacter;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;

class AlphabetTest extends FlxState {
    var isBold:Bool = false;
    var alphabet:Alphabet;

    override function create():Void
    {
        add(FlxGridOverlay.create(10, 10));

        trace("pre alphabet");
        alphabet = new Alphabet(10, 10, '${AlphabetCharacter.ALPHABET.toUpperCase()}\n${AlphabetCharacter.ALPHABET}\n\"Test: Wtf did you say; I\'m so confused!?\"\n${AlphabetCharacter.NUMBERS}\n${AlphabetCharacter.SYMBOLS}');
        trace("post alphabet");

        super.create();
    }

    override function update(e:Float):Void
    {
        super.update(e);

        if (FlxG.keys.justPressed.SPACE) {
            isBold = !isBold;
            reload();
        }
    }

    function reload():Void
    {
        remove(alphabet);

        var a = '${AlphabetCharacter.ALPHABET.toUpperCase()}\n${AlphabetCharacter.ALPHABET}\n\"Test: Wtf did you say; I\'m so confused!?\"\n${AlphabetCharacter.NUMBERS}\n${AlphabetCharacter.SYMBOLS}';
        a = "Text With Space";
    
        alphabet = new Alphabet(10, 10, a, isBold);
        
        add(alphabet);
    }
}