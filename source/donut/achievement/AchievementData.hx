package donut.achievement;

typedef GlobalAchievement = 
{
    id:String,
    name:String,
    description:String,
    secret:Bool
}

class AchievementData
{
    public static var achievements:Map<String, GlobalAchievement> = 
    [
        "startup" => {id: "startup", name: "Welcome", description: "Start the game for the first time!", secret: false},
        "week1" => {id: "week1", name: "Donut", description: "Beat Week 1", secret: false},
        "week2" => {id: "week2", name: "Donut+", description: "Beat Week 2", secret: false},
        "week3" => {id: "week3", name: "Donut++", description: "Beat Week 3", secret: false},
        //"nutsdiff" => {id: "nutsdiff", name: "Challenged", description: "Play on the NUTS difficulty!", secret: false},
        //"dingdongdoomnuts" => {id: "dingdongdoomnuts", name: "INSANITY", description: "FC DingDongDoom on NUTS!", secret: false},
        //"dingdongdoomnuts1try" => {id: "dingdongdoomnuts1try", name: "INSANITY+", description: "FC DingDongDoom on NUTS first try!", secret: false},
        "dingdongdoomhard" => {id: "dingdongdoomhard", name: "INSANITY", description: "FC DingDongDoom on HARD!", secret: false},
        "konami" => {id: "konami", name: "REAL ocean", description: "'can you add REAL ocean achievement for entering the konami code in the menus'", secret: true},
        "testsong" => {id: "testsong", name: "Lurker", description: "You're not supposed to play that!!", secret: true},
        //"allergynotesoff" => {id: "allergynotesoff", name: "Disobedience", description: "Turn off the Allergy Notes before beating Story Mode!", secret: true},
        "unknown" => {id: "unknown", name: "???", description: "???", secret: true},
    ];
    
    public static var sortedList:Array<String> = ["startup", "week1", "week2", "week3", "dingdongdoomhard", "konami", "testsong"];

    public static function init():Void
    {
        var savedData:Map<String, Bool> = FlxG.save.data.achievementData;

        if (savedData == null || Lambda.count(savedData) < Lambda.count(achievements))
        {
            // not found, lets generate!
            var localData:Map<String, Bool> = [];

            for (key in achievements.keys())
            {   
                localData.set(key, false);
            }


            FlxG.save.data.achievementData = localData;
            FlxG.save.flush();
        }

        GlobalTracker.localAchievements = FlxG.save.data.achievementData;
        trace("Initialized Achievement Data!");
    }

    public static function save():Void
    {
        FlxG.save.data.achievementData = GlobalTracker.localAchievements;
        FlxG.save.flush();
    }

    public static function resetLocal():Void
    {
        for (key in GlobalTracker.localAchievements.keys())
        {
            GlobalTracker.localAchievements.set(key, false);
        }

        FlxG.save.data.achievementData = GlobalTracker.localAchievements;
        FlxG.save.flush();
    }

    public static function isUnlocked(id:String):Bool
    {
        return GlobalTracker.localAchievements.get(id);
    }

    public static function unlock(id:String, ?onUnlock:Void->Void):Void
    {
        // Doesn't exist
        if (GlobalTracker.localAchievements.get(id) == null || GlobalTracker.localAchievements.get(id) 
            || FlxG.save.data.cheatedUnlock)
            return;

        GlobalTracker.localAchievements.set(id, true);

        FlxG.log.add("Unlocked achievement: " + id);

        if (onUnlock != null)
            onUnlock();
    }
}
