package lycan.util;

#if cpp

import flash.display.Bitmap;
import flash.utils.ByteArray;
import haxe.io.Path;
import openfl.display.Bitmap;
import openfl.display.PNGEncoderOptions;
import sys.io.FileOutput;

// Saves a bitmap image to a file
// Requires the systools haxelib and a platform that supports it (not flash or js)
class SaveBitmap {
    public static function save(path:Path, bitmap:Bitmap):Void {
        Sure.sure(bitmap != null);
        Sure.sure(path.file != null);
        Sure.sure(path.ext == "png");
        
        var png:ByteArray = null;
        #if lime_legacy
        png = bitmap.bitmapData.encode(path.ext);
        #else
        png = bitmap.bitmapData.encode(bitmap.bitmapData.rect, new PNGEncoderOptions());
        #end
        Sure.sure(png != null);
        
        var file:FileOutput = sys.io.File.write(path.toString(), true);
        Sure.sure(file != null);
        
        file.writeString(png.readUTFBytes(png.length));
        file.close();
    }
}

#end