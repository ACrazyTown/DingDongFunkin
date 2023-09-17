package;

import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxState;
import openfl.Lib;
import Conductor.BPMChangeEvent;
import flixel.addons.ui.FlxUIState;

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	public var curStep:Int = 0;
	public var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create():Void
	{
		super.create();

		if (!FlxTransitionableState.skipNextTransOut) 
			openSubState(new CustomFadeTransition(0.7, true));

		FlxTransitionableState.skipNextTransOut = false;
	}
	
	override function update(elapsed:Float)
	{
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		lastBeat = curStep;
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}

		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void {}

	// from psych
	public static function switchState(nextState:FlxState) 
	{
		// Custom made Trans in
		if (PlayState.instance != null)
			PlayState.instance.camHUD.visible = false;

		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		if (!FlxTransitionableState.skipNextTransIn) 
		{
			leState.openSubState(new CustomFadeTransition(0.6, false));
			if (nextState == FlxG.state) 
			{
				CustomFadeTransition.finishCallback = function() 
				{
					FlxG.resetState();
				};
			} 
			else 
			{
				CustomFadeTransition.finishCallback = function() 
				{
					FlxG.switchState(nextState);
				};
			}
			return;
		}

		FlxG.switchState(nextState);
		FlxTransitionableState.skipNextTransIn = false;
	}

	public static function resetState() 
	{
		MusicBeatState.switchState(FlxG.state);
	}

	public static function getState():MusicBeatState 
	{
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		return leState;
	}
}
