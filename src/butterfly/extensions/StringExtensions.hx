package butterfly.extensions;

using StringTools;

class StringExtensions {
    static public function IsNullOrWhiteSpace(s:String):Bool {
        return s == null || s.trim().length == 0;
    }
}