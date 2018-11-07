package lycan.ui;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

interface Layout {
	public function apply<T>(group:FlxSpriteGroup, width:Float = 0, height:Float = 0):Void;
}

// TODO distinction between full y alignment and individual line alignment
class TextLayout implements Layout {
	public var alignment:Alignment;
	public var spacingX:Float;
	public var spacingY:Float;
	
	public function new(align:Alignment, spacingX:Float, spacingY:Float) {
		this.alignment = align;
		this.spacingX = spacingX;
		this.spacingY = spacingY;
	}
	
	public function apply(group:FlxSpriteGroup, width:Float = 0, height:Float = 0):Void {
		var currentLine:Array<FlxSprite> = [];
		var currentLineX:Float = 0;
		var currentLineY:Float = group.y;
		var currentLineWidth:Float = 0;
		var currentLineHeight:Float = 0;
		
		currentLineY = group.y;
		
		function completeLine():Void {
			// Set x position
			currentLineX = switch alignment {
				// LEFT
				case LEFT, TOP_LEFT, BOTTOM_LEFT:
					group.x;
				// RIGHT
				case RIGHT, TOP_RIGHT, BOTTOM_RIGHT:
					group.x + width - currentLineWidth;
				// CENTER (default)
				case _:
					group.x + (width - currentLineWidth) / 2;
				
			}
			
			var i:Int = 0;
			for (s in currentLine) {
				if (i > 0) currentLineX += spacingX;
				s.x = currentLineX;
				currentLineX += s.width;
				
				// Set y position
				s.y = switch alignment {
					// TOP
					case TOP, TOP_LEFT, TOP_RIGHT:
						currentLineY;
					// BOTTOM
					case BOTTOM, BOTTOM_LEFT, BOTTOM_RIGHT:
						currentLineY + currentLineHeight - s.height;
					// MIDDLE
					case _:
						currentLineY + (currentLineHeight - s.height) / 2;
				}
				
				i++;
			}
			
			currentLineY += currentLineHeight + spacingY;
			currentLineWidth = 0;
			currentLineHeight = 0;
			currentLine.splice(0, currentLine.length);
		}
		
		// Add elements to the current line until it would exceed group width
		// (if it's the first element, it's too big for the group so add it to this line anyway)
		group.forEach((e:FlxSprite)->{
			
			// If element exceeds line width, finish current line
			if (currentLine.length > 0 && currentLineWidth + e.width > width) {
				completeLine();
			}
			
			// Add element to current line
			currentLineWidth += e.width + (currentLine.length > 0 ? spacingX : 0);
			currentLineHeight = Math.max(e.height, currentLineHeight);
			currentLine.push(e);
		});
		
		// Complete the last line
		completeLine();
	}
}

class VerticalLayout implements Layout {
	public var alignment:Alignment;
	public var spacing:Float;
	
	public function new(align:Alignment, spacing:Float = 0) {
		this.alignment = align;
		this.spacing = spacing;
	}
	
	public function apply(group:FlxSpriteGroup, width:Float = 0, height:Float = 0):Void {
		var currentY:Float = group.y;
		
		if (width == 0) {
			group.forEach((b:FlxSprite)->{
				if (b.width > width) width = b.width;
			});
		}
		
		group.forEach(function(b:FlxSprite) {
			b.y = currentY;
			currentY += b.height + spacing;
			
			switch (alignment) {
				case LEFT:
					b.x = group.x;
				case RIGHT:
					b.x = group.x + width - b.width;
				case CENTER:
					b.x = group.x + (width - b.width) / 2;
				default:
			}
		});
	
	}
}

class HorizontalLayout implements Layout {
	public var alignment:Alignment;
	public var spacing:Float;
	
	public function new(align:Alignment, spacing:Float = 0) {
		this.alignment = align;
		this.spacing = spacing;
	}
	
	public function apply(group:FlxSpriteGroup, width:Float = 0, height:Float = 0):Void {
		var currentX:Float = group.x;
		
		if (height == 0) {
			group.forEach((b:FlxSprite)->{
				if (b.height > height) height = b.height;
			});
		}
		
		group.forEach(function(b:FlxSprite) {
			b.x = currentX;
			currentX += b.width + spacing;
			
			switch (alignment) {
				case TOP:
					b.y = group.y;
				case BOTTOM:
					b.y = group.y + height - b.height;
				case MIDDLE:
					b.y = group.y + (height - b.height) / 2;
				default:
			}
		});
	
	}
}