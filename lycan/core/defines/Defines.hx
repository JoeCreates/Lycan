package lycan.core.defines;

#if macro

import haxe.macro.Compiler;
import haxe.macro.Context;

using StringTools;

// Defines that the user can set to include/exclude modules of Lycan
private enum UserDefines {
    // TODO
}

// Defines that consolidate internal features and complex conditions into single defines
private enum EngineDefines {
    // TODO
}

class Defines {
    public static function run() {
        checkDefines();
        makeDefines();
    }

    private static function checkDefines():Void {
        for (define in EngineDefines.getConstructors()) {
            abortIfDefined(define);
        }
    }

    private static function abortIfDefined(define:String):Void {
        if (defined(define)) {
            Context.fatalError('$define can only be defined by Lycan', Context.currentPos());
        }
    }

    private static function makeDefines():Void {

    }

    private static inline function defined(define:Dynamic):Void {
        return Context.defined(Std.string(define));
    }

    private static inline function define(define:Dynamic):Void {
        Compiler.define(Std.string(define));
    }
}

#end