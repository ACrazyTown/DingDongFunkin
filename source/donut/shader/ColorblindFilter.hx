package donut.shader;

import openfl.filters.ColorMatrixFilter;

using StringTools;

enum ColorblindType
{
    None;
    Deuteranopia;
    Protanopia;
    Tritanopia;
}

class ColorblindFilter
{
    public static var matrixes:Map<ColorblindType, Array<Float>> = [
        Deuteranopia => [0.43, 0.72, -.15, 0, 0, 0.34, 0.57, 0.09, 0, 0, -.02, 0.03, 1, 0, 0, 0, 0, 0, 1, 0],
        Protanopia => [0.20, 0.99, -.19, 0, 0, 0.16, 0.79, 0.04, 0, 0, 0.01, -.01, 1, 0, 0, 0, 0, 0, 1, 0],
        Tritanopia => [0.97, 0.11, -.08, 0, 0, 0.02, 0.82, 0.16, 0, 0, 0.06, 0.88, 0.18, 0, 0, 0, 0, 0, 1, 0]
    ];

    public static function get(type:ColorblindType):ColorMatrixFilter
    {
        if (type == None)
            return null;

        var matrix:Array<Float> = matrixes.get(type);
        var filter:ColorMatrixFilter = null;

        if (matrix != null)
            filter = new ColorMatrixFilter(matrixes.get(type));

        return filter;
    }

    public static function fromString(string:String):ColorblindType
    {
        var val:ColorblindType = None;

        switch (string.toLowerCase())
        {
            case "deuteranopia": val = Deuteranopia;
            case "protanopia": val = Protanopia;
            case "tritanopia": val = Tritanopia;
            case "none": val = None;
            default: val = None;
        }

        return val;
    }

    public static function toString(type:ColorblindType):String
    {
        var val:String = "None";

        switch (type)
        {
            case Deuteranopia: val = "Deuteranopia";
            case Protanopia: val = "Protanopia";
            case Tritanopia: val = "Tritanopia";
            case None: val = "None";
            default: val = "None";
        }

        return val;
    }
}
