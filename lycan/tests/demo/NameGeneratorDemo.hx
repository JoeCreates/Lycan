package lycan.tests.demo;

import lycan.util.namegen.Names;
import lycan.util.namegen.NameGenerator;
import lycan.util.PrefixTrie;

class NameGeneratorDemo extends BaseDemoState {
	private var nameGenerator:NameGenerator;
	private var trie:PrefixTrie;
	
	override public function create():Void {
		super.create();
		
		// TODO implement markov chain model, build trie to avoid offering duplicates, use similarity metrics to offer a bunch of best/similar-to names from a big list of generated names (also have a "only-names-containing" option)
		var names = Names.elfForenames.concat(Names.richForenames).concat(Names.journoForenames);
		nameGenerator = new NameGenerator([
			"ileen",
			"zulema",
			"lauri",
			"cara",
			"martin",
			"cinda",
			"greg",
			"christie",
			"sheba",
			"alfonso",
			"versie",
			"jackelyn",
			"murray",
			"rosaura",
			"aracelis",
			"mel",
			"doretha",
			"sabrina",
			"jacquelynn",
			"joann",
			"kacey",
			"jone",
			"rona",
			"alexa",
			"sanora",
			"phylicia",
			"ladonna",
			"aleshia",
			"lilli",
			"keva",
			"marlon",
			"elden",
			"aisha",
			"michaela",
			"emmy",
			"gudrun",
			"venetta",
			"tarah",
			"ethel",
			"georgina",
			"miss",
			"eulalia",
			"yoko",
			"victor",
			"arlen",
			"keeley",
			"houston",
			"katy",
			"lorita",
			"charla"], 3, 0.005);
		trie = new PrefixTrie();
		for (name in names) {
			trie.insert(name.name);
		}
		for (name in names) {
			Sure.sure(trie.find(name.name));
		}
		//trace(tree.getWords());
		
		for (i in 0...30) {
			trace(nameGenerator.generate());
		}
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		lateUpdate(dt);
	}
}