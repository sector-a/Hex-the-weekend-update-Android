package;

import flixel.input.actions.FlxActionInput;
import lime.app.Application;
import openfl.Lib;
import flixel.text.FlxText;
import flixel.input.gamepad.FlxGamepad;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxSubState;
#if mobileC
import ui.FlxVirtualPad;
#end

class MusicBeatSubstate extends FlxSubState
{
	public function new()
	{
		super();
	}

	override function create()
	{
		super.create();
		Application.current.window.onFocusIn.add(onWindowFocusIn);
		Application.current.window.onFocusOut.add(onWindowFocusOut);
	}

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	#if mobileC
	var _virtualpad:FlxVirtualPad;

	var trackedinputs:Array<FlxActionInput> = [];

	// adding virtualpad to state
	public function addVirtualPad(?DPad:FlxDPadMode, ?Action:FlxActionMode) {
		_virtualpad = new FlxVirtualPad(DPad, Action);
		_virtualpad.alpha = 0.75;
		add(_virtualpad);
		controls.setVirtualPad(_virtualpad, DPad, Action);
		trackedinputs = controls.trackedinputs;
		controls.trackedinputs = [];

		#if android
		controls.addAndroidBack();
		#end
	}
	
	override function destroy() {
		controls.removeFlxInput(trackedinputs);

		Application.current.window.onFocusIn.remove(onWindowFocusOut);
		Application.current.window.onFocusIn.remove(onWindowFocusIn);
		
		super.destroy();
	}
	#else
	public function addVirtualPad(?DPad, ?Action){};
	#end

        public function switchState(nextState:MusicBeatState, goToLoading:Bool = true, trans:Bool = true, song:Bool = false)
	{
		if (fuckYou)
			return;
		fuckYou = true;
		Debug.logTrace("switching");
		if (trans)
		{
			transitionOut(function()
			{
				lastState = this;
				if (goToLoading)
				{
					var state:FlxState = new LoadingScreen(nextState, song);

					@:privateAccess
					FlxG.game._requestedState = state;
				}
				else
				{
					@:privateAccess
					FlxG.game._requestedState = nextState;
				}
				Debug.logTrace("switched");
			});
		}
		else
		{
			lastState = this;
			if (goToLoading)
			{
				var state:FlxState = new LoadingScreen(nextState, song);

				@:privateAccess
				FlxG.game._requestedState = state;
			}
			else
			{
				@:privateAccess
				FlxG.game._requestedState = nextState;
			}
			Debug.logTrace("switched");
		}
	}

	override function update(elapsed:Float)
	{
		// everyStep();
		var nextStep = updateCurStep();

		if (nextStep >= 0)
		{
			if (nextStep > curStep)
			{
				for (i in curStep...nextStep)
				{
					curStep++;
					updateBeat();
					stepHit();
				}
			}
			else if (nextStep < curStep)
			{
				// Song reset?
				curStep = nextStep;
				updateBeat();
				stepHit();
			}
		}

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		if (gamepad != null)
			KeyBinds.gamepad = true;
		else
			KeyBinds.gamepad = false;

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		lastBeat = curBeat;
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		return lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// do literally nothing dumbass
	}

	function onWindowFocusOut():Void
	{
		if (PlayState.inDaPlay)
		{
			if (!PlayState.instance.paused && !PlayState.instance.endingSong && PlayState.instance.songStarted)
			{
				Debug.logTrace("Lost Focus");
				PlayState.instance.openSubState(new PauseSubState());
				PlayState.boyfriend.stunned = true;

				PlayState.instance.persistentUpdate = false;
				PlayState.instance.persistentDraw = true;
				PlayState.instance.paused = true;

				PlayState.instance.vocals.stop();
				FlxG.sound.music.stop();
			}
		}
	}

	function onWindowFocusIn():Void
	{
		Debug.logTrace("IM BACK!!!");
		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
	}
}
