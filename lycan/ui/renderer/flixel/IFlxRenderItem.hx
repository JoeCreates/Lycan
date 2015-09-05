package lycan.ui.renderer.flixel;

import flixel.group.FlxSpriteGroup;

interface IFlxRenderItem {
	function addTo(group:FlxSpriteGroup):Dynamic;
	function removeFrom(group:FlxSpriteGroup):Dynamic;
}