package lycan.ui;

import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class TextButton extends FlxButton {
	public function new(text:String, onClick:Void->Void, frameWidth:Int = 0) {
		super(0, 0, text, onClick);
		label.borderStyle = FlxTextBorderStyle.OUTLINE;
		label.borderColor = ColorPresets.BLACK;
		label.borderSize = 2;
		label.color = 0xeeeeee;
		label.autoSize = true;
		label.alignment = "center";
		label.wordWrap = false;
		
		scrollFactor.set(1, 1);
		maxInputMovement = 15;
		allowSwiping = false;
		
		label.fieldWidth = 0;
		label.drawFrame(true);
		
		makeGraphic(frameWidth, Std.int(label.height + 10), FlxColor.TRANSPARENT, false, "textbuttonbg");
		
		updateHitbox();
		centerOffsets();
		
		label.offset.x = Math.floor(label.offset.x);
		offset.x = Math.floor(offset.x);
		
		for (i in [FlxButton.NORMAL, FlxButton.PRESSED, FlxButton.HIGHLIGHT]) {
			labelAlphas[i] = 1;
			labelOffsets[i].set((width - label.width) / 2, (height - label.height) / 2);
			statusAnimations[i] = "normal";
		}
		
		status = FlxButton.NORMAL;
	}
}