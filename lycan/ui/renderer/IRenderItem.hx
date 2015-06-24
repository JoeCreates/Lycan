package lycan.ui.renderer;

import flixel.math.FlxPoint;

interface IRenderItem {
	function get_x():Int;
	function set_x(x:Int):Int;
	function get_y():Int;
	function set_y(y:Int):Int;
	function get_width():Int;
	function set_width(width:Int):Int;
	function get_height():Int;
	function set_height(height:Int):Int;
	function get_scale():FlxPoint;
	function set_scale(scale:FlxPoint):FlxPoint;
	function show():Void;
	function hide():Void;
	//function raise():Void;
}