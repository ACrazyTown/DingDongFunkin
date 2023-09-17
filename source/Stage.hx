typedef ResizeOptions = 
{
    sizeX:Float,
    ?sizeY:Float,
    multiplyWidth:Bool
}

typedef StageAsset = 
{
    x:Float,
    y:Float,
    name:String,
    library:String,
    anims:Array<String>,
    loop:Bool,
    scroll:Array<Float>,
    ?gSize:ResizeOptions
}

typedef Stage = 
{
    stageZoom:Float,
    camZoom:Float,
    name:String,
    assets:Array<StageAsset>
}
