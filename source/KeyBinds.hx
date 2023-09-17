package;

import flixel.input.keyboard.FlxKey;

class KeyBinds
{
    public static var defaultBinds:Map<String, Array<FlxKey>> = 
    [
        "ui_up" => [UP, W],
        "ui_left" => [LEFT, A],
        "ui_down" => [DOWN, S],
        "ui_right" => [RIGHT, D],
        "note_up" => [W, UP],
        "note_left" => [A, LEFT],
        "note_down" => [S, DOWN],
        "note_right" => [D, RIGHT],
        "accept" => [ENTER, NONE],
        "back" => [BACKSPACE, ESCAPE],
        "pause" => [ENTER, ESCAPE],
        "reset" => [R, NONE],
    ];

    public static var keyBinds:Map<String, Array<FlxKey>> = null;

    public static function reset():Void
    {
        keyBinds.clear();
        for (key in defaultBinds.keys())
            keyBinds.set(key, defaultBinds[key].copy());
    }

    public static function load():Void
    {
        keyBinds = new Map<String, Array<FlxKey>>();

        var binds:Map<String, Array<FlxKey>> = defaultBinds;
        if (FlxG.save.data.keyBinds != null)
            binds = FlxG.save.data.keyBinds;/*.copy();*/

        for (key in binds.keys())
            keyBinds.set(key, binds[key].copy());

        trace("LOADED BINDS! " + keyBinds);
    }

    public static function save(?reload:Bool = true):Void
    {
        FlxG.save.data.keyBinds = keyBinds;
        FlxG.save.flush();

        if (reload)
            refresh();
    }

    public static function refresh():Void
    {
        PlayerSettings.player1.controls.loadKeyBinds(false);
    }

    public static function compare(a:Map<Dynamic, Dynamic>, b:Map<Dynamic, Dynamic>):Bool
    {
        for (key in a.keys())
        {
            if (!b.exists(key) || a.get(key) != b.get(key))
                return false;
        }

        return true;
    }

    public static function debug():Void
    {
        Sys.println("---");
        Sys.println("DEFAULT : " + defaultBinds);
        Sys.println("USER : " + keyBinds);
        Sys.println("ARE SAME? " + compare(defaultBinds, keyBinds));
    }
}
