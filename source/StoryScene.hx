import flixel.FlxG;
import flixel.FlxSprite;

class StoryScene extends MusicBeatState
{
	public var handler:VideoSprite;

	public var path:String = "";

	public function new(bruh)
	{
		path = bruh;
		super();
	}

	public override function load()
	{
		handler = new VideoSprite();
	}

	public override function update(elapsed)
	{
		super.update(elapsed);
	}

	public override function create()
	{
		handler.playVideo(Paths.video(path));
		handler.finishCallback = function()
		{
			switchState(new BruhADiagWindow(PlayState.SONG.songId));
		};
		super.create();
	}
}
