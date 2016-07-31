package lycan.ui;

import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;

class CinematicText extends FlxSpriteGroup {
	public var letters:Array<CinematicLetter>;
	public var fullText:FlxText;
	public var minYMotion:Float = 10;
	public var maxYMotion:Float = 20;
	public var autoHide:Bool;
	public var finishedShowing(default, set) = false;
	public var onFinishedShowing:Void->Void;
	public var finishedHiding(default, set) = false;
	public var onFinishedHiding:Void->Void;
	
	public function new(x:Float, y:Float, text:String, size:Int = 24, spacing:Float = 0, font:String = "fairfax", autoHide:Bool = false, ?letterCreator:String->Int->String->CinematicLetter) {
		super();
		
		if (letterCreator == null) {
			letterCreator = function(char:String, size:Int, font:String):CinematicLetter {
				return new CinematicLetter(char, size, font);
			};
		}
		
		letters = new Array<CinematicLetter>();
		this.autoHide = autoHide;
		
		// Populate full text slowly to get position of each character
		fullText = new FlxText(0, 0, 0, "", size);
		fullText.font = font;
		var cumulativeWidth:Float = 0;
		
		for (i in 0...text.length) {
			fullText.text += text.charAt(i);
			fullText.calcFrame();
			fullText.updateHitbox();
			var letter:CinematicLetter = letterCreator(text.charAt(i), size, font);
			letter.setPosition(x + cumulativeWidth + i * spacing, y);
			cumulativeWidth = fullText.width;
			letters.push(letter);
			letter.alpha = 0;
			add(letter);
		}
	}
	
	public function show():Void {
		var i = 0;
		for (letter in letters) {
			showLetter(letter, i++);
		}
	}
	
	public function hide():Void {
		var i = 0;
		for (letter in letters) {
			hideLetter(letter, i++);
		}
	}
	
	public function showLetter(letter:CinematicLetter, index:Int):Void {
		throw "Implement me";
	}
	
	public function hideLetter(letter:CinematicLetter, index:Int):Void {
		throw "Implement me";
	}
	
	private function set_finishedShowing(finished:Bool):Bool {
		if (this.finishedShowing == finished) {
			return finished;
		}
		this.finishedShowing = finished;
		if (onFinishedShowing != null) {
			onFinishedShowing();
		}
		return finished;
	}
	
	private function set_finishedHiding(finished:Bool):Bool {
		if (this.finishedHiding == finished) {
			return finished;
		}
		this.finishedHiding = finished;
		if (onFinishedHiding != null) {
			onFinishedHiding();
		}
		return finished;
	}
	
	override public function destroy():Void {
		for (item in group) {
			item.destroy();
		}
		group.clear();
		super.destroy();
	}
}

class CinematicLetter extends FlxText {
	public function new(char:String, size:Int = 24, font:String = "fairfax") {
		super(0, 0, 0, char, size);
		this.font = font;
	}
}