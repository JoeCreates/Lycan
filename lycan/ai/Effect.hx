package lycan.ai;

typedef Effect = {
	var id:Int;
	var effect:Dynamic->Void; // Effect accepts data that it acts on e.g. the game world
}