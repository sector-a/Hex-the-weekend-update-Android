package;

import openfl.events.KeyboardEvent;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
#if mobileC
import ui.FlxVirtualPad;
import flixel.FlxCamera;
#end

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	var stageSuffix:String = "";

	#if mobileC
	var virtualpad:FlxVirtualPad;
	#end

	public function new(x:Float, y:Float)
	{
		var daStage = PlayState.Stage.curStage;
		var daBf:String = '';
		switch (PlayState.boyfriend.curCharacter)
		{
			case 'bf-pixel':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			default:
				daBf = 'bf';
		}

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix, "shared"));
		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');

		#if mobileC
		virtualpad = new FlxVirtualPad(NONE, A_B);
		virtualpad.alpha = 0.75;
		add(virtualpad);
		var camcontrol = new FlxCamera();
		FlxG.cameras.add(camcontrol);
		camcontrol.bgColor.alpha = 0;
		virtualpad.cameras = [camcontrol];
		#end
	}

	var startVibin:Bool = false;

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT #if android || virtualpad.buttonA.justPressed #end)
		{
			endBullshit();
		}

		if (FlxG.save.data.InstantRespawn)
		{
			PlayState.startTime = 0;
			PlayState.instance.restart();
			close();
			PlayState.loadRep = false;
			PlayState.stageTesting = false;
		}

		if (controls.BACK #if android || virtualpad.buttonB.justPressed #end)
		{
			FlxG.sound.music.stop();

			PlayState.startTime = 0;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, PlayState.instance.handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, PlayState.instance.releaseInput);
			PlayState.instance.switchState(new HexMainMenu(HexMenuState.loadHexMenu("main-menu")));
			PlayState.loadRep = false;
			PlayState.stageTesting = false;
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix, "shared"));
			FlxG.sound.music.volume = 0.6;
			startVibin = true;
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		super.update(elapsed);
	}

	override function beatHit()
	{
		super.beatHit();

		if (startVibin && !isEnding)
		{
			bf.playAnim('deathLoop', true);
		}
		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix, "shared"));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					FlxG.camera.follow(null);
					PlayState.startTime = 0;
					// PlayState.instance.restart();
					PlayState.stageTesting = false;
					// close();
					switchState(new PlayState());
				});
			});
		}
	}
}
