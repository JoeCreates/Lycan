package lycan.ui.renderer.flixel;
import flixel.group.FlxGroup;

interface IFlxRenderItem {
	function addTo(group:FlxGroup):Dynamic;
	function removeFrom(group:FlxGroup):Dynamic;
}