package lycan.ui.renderer.flixel;
import flixel.group.FlxGroup;

interface IFlxRenderItem {
	function addTo(group:FlxGroup):Void;
	function removeFrom(group:FlxGroup):Void;
}