package lycan.util;

import haxe.Json;
import haxe.macro.Context;

using StringTools;
using Lambda;

class JsonReader {
    macro public static function readFile(path:String):ExprOf<String> {
        var content = loadFileAsString(path);
        try Json.parse(content) catch (e:Dynamic) {
            haxe.macro.Context.error('Json from $path failed to validate: $e', Context.currentPos());
        }
        return toExpr(content);
    }
    
    #if macro
    static function toExpr(v:Dynamic) {
        return Context.makeExpr(v, Context.currentPos());
    }
    
    static private function loadFileAsString(path:String) {
        try {
            var p = Context.resolvePath(path);
            Context.registerModuleDependency(Context.getLocalModule(),p);
            return sys.io.File.getContent(p);
        } 
        catch(e:Dynamic) {
            return haxe.macro.Context.error('Failed to load file $path: $e', Context.currentPos());
        }
    }
    #end
}