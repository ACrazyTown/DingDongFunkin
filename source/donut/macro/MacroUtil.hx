package donut.macro;

import sys.FileSystem;
import haxe.macro.Expr.ExprOf;

using StringTools;

class MacroUtil
{
    public static macro function getGitCommitHash():ExprOf<String>
    {
        #if !display
        // Get the current line number.
        var pos = haxe.macro.Context.currentPos();

        var process = new sys.io.Process('git', ['rev-parse', 'HEAD']);
        if (process.exitCode() != 0)
        {
            var message = process.stderr.readAll().toString();
            haxe.macro.Context.info('[WARN] Could not determine current git commit; is this a proper Git repository?', pos);
        }

        // read the output of the process
        var commitHash:String = process.stdout.readLine();
        var commitHashSplice:String = commitHash.substr(0, 7);

        // haxe.macro.Context.info('[INFO] We are building in git commit ${commitHashSplice}', pos);

        // Generates a string expression
        return macro $v{commitHashSplice};
        #else
        // `#if display` is used for code completion. In this case returning an
        // empty string is good enough; We don't want to call git on every hint.
        var commitHash:String = "";
        return macro $v{commitHash};
        #end
    }

    public static macro function getCharacters():ExprOf<Array<String>>
    {
        return macro $v{_getCharacters()};
    }

    public static macro function getGfVersions():ExprOf<Array<String>>
    {
        var characters:Array<String> = _getCharacters();
        var gfs:Array<String> = [];

        for (char in characters)
            if (char.startsWith("gf"))
                gfs.push(char);

        return macro $v{gfs};
    }

    static function _getCharacters():Array<String>
    {
        var _charFiles:Array<String> = FileSystem.readDirectory(FileSystem.absolutePath("./assets/preload/characters"));

        var characters:Array<String> = [];
        for (_charName in _charFiles)
            characters.push(_charName.split(".")[0]);

        return characters;
    }
}