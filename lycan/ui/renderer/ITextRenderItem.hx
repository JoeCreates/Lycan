package lycan.ui.renderer;

interface ITextRenderItem extends IRenderItem {
	function get_text():String;
	function set_text(s:String):String;
}