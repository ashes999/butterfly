package butterfly.html;

using StringTools;

class HtmlTag
{
  private static var attributePairsRegex:EReg = new EReg('([a-zA-Z0-9_\\-]+)=[\'"]([^\'"]+)[\'"]', "ig");

  public var html(default, null):String;
  private var attributes:Map<String, String> = new Map<String, String>();

  public function new(tagName:String, html:String)
  {
    this.html = html;

    // parse attributes
    var start = html.indexOf(tagName) + tagName.length;
    var stop = html.indexOf("/>");

    var attributesHtml = html.substring(start, stop);
    // To allow quotating inside an attribute value, convert all single- quotation
    // marks temporarily to {}. We'll convert them back later.
    attributesHtml = attributesHtml.replace("'", "{}");
    if (attributePairsRegex.match(attributesHtml)) {
      // Iterate and extract all attributes. This is complicated beecause we don't
      // know how many attributes to expect, and Haxe doesn't expose a match count.
      // This is a horrible, terrible hack, but I don't have to worry about quotations
      // and funky parsing if I do this. Nobody puts @@@ into their HTML attributes.
      var delimiter = "@@";
      var subst = '${delimiter}$1${delimiter}=${delimiter}$2${delimiter}';
      var matches = attributePairsRegex.replace(attributesHtml, subst); // eg. @@show-counts@@=@@true@@
      // Un-quote any attribute values that had quotes converted into {}
      matches = matches.replace('{}', "'");

      while (matches.indexOf(delimiter) > -1) {
        // Get the very next key/value pair. The magic number +2 is the delimiter length.
        var keyStart = matches.indexOf(delimiter) + 2;
        var keyEnd = matches.indexOf(delimiter, keyStart + 2);
        var valueStart = matches.indexOf(delimiter, keyEnd + 3) + 2;
        var valueEnd = matches.indexOf(delimiter, valueStart + 2);
        var key = matches.substring(keyStart, keyEnd);
        var value = matches.substring(valueStart, valueEnd);
        matches = matches.substring(valueEnd + 2);
        attributes.set(key, value);
      }
    }
  }

  // This function is something of a travesty. Since haxe doesn't allow us to use
  // && or || to coalesce nulls with string values, this is a convenient way
  // to write "get me this, if it exists, or use the default of that."
  public function attribute(attributeName:String, defaultValue:String = "") : String
  {
    if (this.attributes.exists(attributeName))
    {
      return this.attributes.get(attributeName);
    } else {
      return defaultValue;
    }
  }
}
