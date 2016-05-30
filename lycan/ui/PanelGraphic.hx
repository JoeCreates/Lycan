package lycan.ui;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

/**
 * A resizable panel graphic for use with GUI components
 * 
 * @author Joe Williamson
 */
class PanelGraphic extends FlxSpriteGroup {
    
    var topLeftSection:FlxSprite;
    var topRightSection:FlxSprite;
    var bottomLeftSection:FlxSprite;
    var bottomRightSection:FlxSprite;
    var leftSection:FlxSprite;
    var rightSection:FlxSprite;
    var topSection:FlxSprite;
    var bottomSection:FlxSprite;
    var backgroundSection:FlxSprite;
    
    public function new() {
        super();
    }
    
    /**
     * Update panel sections to current panel size
     */
    public function resize():Void {
        
    }
    
}