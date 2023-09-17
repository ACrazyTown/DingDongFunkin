package;

import PlayState.PlayStateChangeables;
import flixel.math.FlxMath;

class Ratings
{
    public static var accuracyPrecision:Int = 2;
    public static var ratings:Array<String> = ["shit", "bad", "good", "sick"];

    public static function generateLetterRank():String
    {
        var ratingCombo:String = "SFC";

        if (PlayState.sicks > 0) ratingCombo = "SFC";
        if (PlayState.goods > 0) ratingCombo = "GFC";
        if (PlayState.bads > 0 || PlayState.shits > 0) ratingCombo = "FC";
        if (PlayState.misses > 0 && PlayState.misses < 10) ratingCombo = "SDCB";
        else if (PlayState.misses >= 10) ratingCombo = "Clear";

        return ratingCombo;
    }
    
    public static function calculateRating(noteDiff:Float, ?customSafeZone:Float):String // Generate a judgement through some timing shit
    {
        var customTimeScale = Conductor.timeScale;

        if (customSafeZone != null)
            customTimeScale = customSafeZone / 166;

        if (FlxG.save.data.botplay)
            return "sick"; // FUNNY
	
        return checkRating(noteDiff, customTimeScale);
    }

    public static function checkRating(ms:Float, ts:Float)
    {
        var rating = "shit";
        
        if (ms <= 166 * ts && ms >= 135 * ts)
            rating = "shit";
        if (ms < 135 * ts && ms >= 90 * ts) 
            rating = "bad";
        if (ms < 90 * ts && ms >= 45 * ts)
            rating = "good";
        if (ms < 45 * ts && ms >= -90 * ts)
            rating = "sick";
        if (ms > -90 * ts && ms <= -45 * ts)
            rating = "good";
        if (ms > -135 * ts && ms <= -45 * ts)
            rating = "bad";
        if (ms > -166 * ts && ms <= -135 * ts)
            rating = "shit";

        return rating;
    }

    public static function calculateRanking(score:Int, accuracy:Float):String
    {
        var ranking:String = "";
        var roundedAccuracy:Float = FlxMath.roundDecimal(accuracy, accuracyPrecision);
        var acc:String = Std.string(roundedAccuracy) + "%";

        if (!PlayStateChangeables.botPlay) 
        {
            ranking = 'Score: $score';
            if (FlxG.save.data.accuracyDisplay)
                ranking += '\nMisses: ${PlayState.misses}\nAccuracy: $acc (${generateLetterRank()})';
        }

        return ranking;
    }
}
