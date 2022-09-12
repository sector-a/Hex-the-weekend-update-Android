package ui;

import flixel.graphics.FlxGraphic;
import flixel.addons.ui.FlxButtonPlus;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.graphics.frames.FlxTileFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.util.FlxDestroyUtil;
import flixel.ui.FlxButton;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.ui.FlxVirtualPad;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import openfl.display.Shape;
import openfl.display.BitmapData;
import flixel.util.FlxColor;

// copyed from flxvirtualpad
class Hitbox extends FlxSpriteGroup
{
    public var hitbox:FlxSpriteGroup;

    var sizex:Int = 320;

    var screensizey:Int = 720;

    public var buttonLeft:FlxButton;
    public var buttonDown:FlxButton;
    public var buttonUp:FlxButton;
    public var buttonRight:FlxButton;
    
    public function new(?widghtScreen:Int)
    {
        super();

        /*if (widghtScreen == null)
            widghtScreen = FlxG.width;*/

        sizex = widghtScreen != null ? Std.int(widghtScreen / 4) : 320;

        
        //add graphic
        hitbox = new FlxSpriteGroup();
        hitbox.scrollFactor.set();

        hitbox.add(add(buttonLeft = createhitbox(0, 0xFF00FF)));

        hitbox.add(add(buttonDown = createhitbox(sizex, 0x00FFFF)));

        hitbox.add(add(buttonUp = createhitbox(sizex * 2, 0x00FF00)));

        hitbox.add(add(buttonRight = createhitbox(sizex * 3, 0xFF0000)));
    }
    
    private function createHintGraphic(Width:Int, Height:Int, Color:Int = 0xFFFFFF):BitmapData
	{
		var shape:Shape = new Shape();

		if (FlxG.save.data.gradientHitboxes)
		{
			shape.graphics.beginFill(Color);
			shape.graphics.lineStyle(3, Color, 1);
			shape.graphics.drawRect(0, 0, Width, Height);
			shape.graphics.lineStyle(0, 0, 0);
			shape.graphics.drawRect(3, 3, Width - 6, Height - 6);
			shape.graphics.endFill();
			shape.graphics.beginGradientFill(RADIAL, [Color, FlxColor.TRANSPARENT], [0.6, 0], [0, 255], null, null, null, 0.5);
			shape.graphics.drawRect(3, 3, Width - 6, Height - 6);
			shape.graphics.endFill();
		}
		else
		{
			shape.graphics.beginFill(Color);
			shape.graphics.lineStyle(10, Color, 1);
			shape.graphics.drawRect(0, 0, Width, Height);
			shape.graphics.endFill();
		}

		var bitmap:BitmapData = new BitmapData(Width, Height, true, 0);
		bitmap.draw(shape);
		return bitmap;
	}

    public function createhitbox(X:Float, color:Int, Y:Float = 0, width:Float = 0, height:Float = 0) {
        var button = new FlxButton(X, Y);
        if (width == 0) {
        	width = FlxG.width / 4;
        }
        if (height == 0) {
        	height = 720;
        }
        button.loadGraphic(createHintGraphic(Std.int(width), Std.int(height), color));

        button.alpha = 0;

    
        button.onDown.callback = function (){
            FlxTween.num(0, FlxG.save.data.hitboxOpacity, .075, {ease: FlxEase.circInOut}, function (a:Float) { button.alpha = a; });
        };

        button.onUp.callback = function (){
            FlxTween.num(FlxG.save.data.hitboxOpacity, 0, .1, {ease: FlxEase.circInOut}, function (a:Float) { button.alpha = a; });
        }
        
        button.onOut.callback = function (){
            FlxTween.num(button.alpha, 0, .2, {ease: FlxEase.circInOut}, function (a:Float) { button.alpha = a; });
        }

        return button;
    }

    override public function destroy():Void
        {
            super.destroy();
    
            buttonLeft = null;
            buttonDown = null;
            buttonUp = null;
            buttonRight = null;
        }
}