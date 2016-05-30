package lycan.util;

class Limits {
    inline public static var INT32_MIN = 
    #if cpp
    -INT32_MAX; // This decimal constant is unsigned only in ISO C90
    #else
    0x80000000;
    #end
    
    inline public static var INT32_MAX = 0x7FFFFFFF;
    
    inline public static var INT16_MIN = -0x8000;
    inline public static var INT16_MAX = 0x7FFF;
    
    inline public static var UINT16_MAX = 0xFFFF;
}