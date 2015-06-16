package lycan.ui.renderer;
import lycan.ui.renderer.IRenderItem;

interface ITextRenderItem extends IRenderItem {
	function get_text():String;
	function set_text(s:String):String;
}