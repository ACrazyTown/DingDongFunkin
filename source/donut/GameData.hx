package donut;

import Note.NoteSkin;
import donut.macro.MacroUtil;
import flixel.util.FlxColor;

using StringTools;

typedef WeekFormat = 
{
    songs:Array<String>,
    colors:Array<FlxColor>,
    icons:Array<String>,
    text:String,
    secret:Array<Bool>,
    week:Int,
    ?hasVideo:Array<Bool>,
    ?dependancyAssets:String
}

typedef WeekFile =
{
    weeks:Array<WeekFormat>
}

class GameData
{
    public static var data:WeekFile = 
    {
        weeks: 
        [
            {
                songs: ["Donut Shop", "Allergy", "Abundance"],
                colors: [0xFF5CD3D3, 0xFF5CD3D3, 0xFF5CD3D3],
                icons: ["ding", "ding", "ding"],
                text: "DingDongDirt",
                secret: [false, false, false],
                hasVideo: [true, false, false],
                week: 1
            },
            {
                songs: ["Nuts", "DingDongDoom"],
                colors: [0xFF9E666B, 0xFF9E666B],
                icons: ["ding-worried", "ding"],
                text: "Finale...?",
                secret: [false, false],
                hasVideo: [true, false],
                week: 2
            },
            {
                songs: ["Shark Rap", "Halloween", "Allergic Reaction", "Forgotten"],
                colors: [0xFF5CD3D3, 0xFF5CD3D3, 0xFF5CD3D3, 0xFFBF3039],
                icons: ["lapis", "ocean", "ding", "micah"],
                text: "Ding's Buds",
                secret: [false, false, false, true],
                week: 3 // not used for anything other than library? so prevent loading same stuff twice?
            },
            {
                songs: ["Donut Shop Old", "Allergy Old"],
                colors: [0xFF9FD444, 0xFF9FD444, 0xFF9FD444],
                icons: ["ding", "ding"],
                text: "Bonus Songs! NUTS!",
                secret: [false, false, false],
                week: 4
            }
        ]
    };

    public static var unlockedWeeks:Array<Bool> = [true, false, false, false];

    public static var characters:Array<String> = MacroUtil.getCharacters();
    public static var gfVersions:Array<String> = MacroUtil.getGfVersions();

    public static var songNoteSkins:Map<String, Array<String>> = [
        "forgotten" => [NoteSkin.DONUT]
    ];

    public static var noteSkins:Array<String> = ["normal", "ding"];
    //public static var stages:Array<String> = ["stage", "donutshop", "volcano-normal", "void", "donutropolis"];

    public static var scrollTexts:Array<String> = 
    [
        "Subscribe to Dorbellprod!",
        "Subscribe to A Crazy Town!",
        "Sorry for the delay.. oops.",
        "Have fun!!",
        "Weeeeeeeeeeeeee",
        "Custom engine based on Kade Engine!",
        "Listen to the OST on Soundcloud!",
        "Shoutout to the lil' team <3",
        "Follow Dorbellprod on Twitter!",
        "Follow A Crazy Town on Twitter!",
        "Shoutouts to MaryShmary for menu art",
        "BREAKING: Local man hospitalized after eating donut, says he's allergic to nuts.",
        "Graphic design is NOT my passion",
        "THERE'S TWO OF THEM!?",
        "Null Object Reference"
    ];

    public static function init():Void
    {
        if (FlxG.save.data.weekUnlocked == null) 
        {
            FlxG.save.data.weekUnlocked = [true, false, false, false];
            FlxG.save.flush();
        }

        unlockedWeeks = FlxG.save.data.weekUnlocked;
    }

    public static function getWeekSongs(week:Int = 1):Array<String>
    {
        if (week > unlockedWeeks.length || week < unlockedWeeks.length)
            return null;

        var songs:Array<String> = data.weeks[week - 1].songs;

        if (!GameData.unlockedWeeks[week - 1])
        {
            for (i in 0...songs.length)
                songs[i] = "???";
        }

        return songs;
    }

    public static function getWeekText(week:Int = 1):String
    {
        if (week > unlockedWeeks.length || week < unlockedWeeks.length)
            return null;

        return (GameData.unlockedWeeks[week - 1]) ? GameData.data.weeks[week - 1].text : "???";
    }

    public static function refreshUnlocked():Array<Bool>
    {
        var data:Array<Bool> = FlxG.save.data.weekUnlocked;
        if (data == null)
            data = [true, false, false, false];
        return unlockedWeeks = data;
    }

    public static function setUnlocked(week:Int = 1, value:Bool = false):Bool
    {
        if (week > unlockedWeeks.length || week < unlockedWeeks.length)
            return false;

        unlockedWeeks[week - 1] = value;
        FlxG.save.data.weekUnlocked = unlockedWeeks;
        FlxG.save.flush();
        refreshUnlocked();

        return unlockedWeeks[week - 1];
    }

    public static final stages:Array<String> = ["donutshop", "void", "volcano", "donutdodger", "donutropolis"];
}
