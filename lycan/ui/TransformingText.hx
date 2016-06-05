package lycan.ui;
import lycan.util.algorithm.StringTransforms;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import lycan.util.algorithm.StringTransforms.EditOperation;
import msignal.Signal.Signal0;
import msignal.Signal.Signal1;

// Text that transforms from one string to another by executing a series of edit operations
class TransformingText extends FlxTypedSpriteGroup<TransformingLetter> {
    public var signal_operationHandled(default, null) = new Signal1<EditOperation>(); // Fires when a string operation happens
    public var signal_operationsHandled(default, null) = new Signal0(); // Fires when all operations have been executed

    private var letters:Array<TransformingLetter>;
    private var textSize:Int;
    private var spacing:Float;

    private var operations:Array<EditOperation>;
    private var opIdx:Int; // Index of the next operation

    public function new(x:Float, y:Float, initialText:String, operations:Array<EditOperation>, size:Int = 24, spacing:Float = 0, font:String = "fairfax") {
        super();
        letters = new Array<TransformingLetter>();
        this.textSize = size;
        this.operations = operations;
        this.spacing = spacing;

        for (i in 0...initialText.length) {
            letters.push(getLetter(initialText.charAt(i)));
        }

        opIdx = 0;
    }

    // Perform the next operation, if there is one
    public function pump():Void {
        Sure.sure(opIdx >= 0);

        if(opIdx < operations.length) {
            handle(operations[opIdx]);
            opIdx++;
        } else {
            signal_operationsHandled.dispatch();
        }
    }

    public function retarget(ops:Array<EditOperation>):Void {
        opIdx = 0;
        operations = ops;
    }

    public function getText():String {
        var s:String = "";
        for (letter in letters) {
            s += letter.text;
        }
        return s;
    }

    private function handle(e:EditOperation):Void {
        switch(e) {
            case EditOperation.DELETE(s, idx):
                Sure.sure(idx >= 0 && idx < letters.length);
                delete(s, idx);
            case EditOperation.INSERT(s, src, target):
                Sure.sure(target >= 0 && target < letters.length);
                insert(s, src, target);
            case EditOperation.KEEP(s, idx):
                Sure.sure(idx >= 0 && idx < letters.length);
                keep(s, idx);
            case EditOperation.SUBSTITUTE(r, i, idx):
                Sure.sure(idx >= 0 && idx < letters.length);
                substitute(r, i, idx);
            default:
                throw "Unhandled string edit operation encountered";
                return;
        }

        signal_operationHandled.dispatch(e);
        layoutLetters();
    }

    private function keep(s:String, idx:Int):Void {
        //trace("Keep element " + s + " at index " + idx);
    }

    private function insert(s:String, src:Int, target:Int):Void {
        //trace("Insert element " + s + " at index " + target + " from " + src);
        letters.insert(target + 1, getLetter(s));
    }

    private function delete(s:String, idx:Int):Void {
        //trace("Delete element " + s + " at index " + idx);
        var letter = letters.splice(idx, 1);
        remove(letter[0], true);
    }

    private function substitute(r:String, i:String, idx:Int):Void {
        //trace("Remove element " + r + " and replace it with " + i + " at index " + idx);
        remove(letters[idx], true);
        //trace("Num letters: " + letters.length);
        letters[idx] = getLetter(i);
    }

    private function layoutLetters():Void {
        var cumulativeX:Float = 0;
        for (letter in letters) {
            letter.x = x + cumulativeX;
            cumulativeX += letter.width + spacing;
        }
    }

    private function getLetter(letter:String):TransformingLetter {
        var txt = new TransformingLetter(letter, textSize);
        add(txt);
        return txt;
    }

    override public function destroy():Void {
        for (item in group) {
            item.destroy();
        }
        group.clear();
        super.destroy();
    }
}

class TransformingLetter extends FlxText {
    public function new(char:String, size:Int = 24, font:String = "fairfax") {
        super(0, 0, 0, char, size);
        this.font = font;
    }
}