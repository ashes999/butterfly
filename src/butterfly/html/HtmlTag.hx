package butterfly.html;

using StringTools;

class HtmlTag
{
	private static var attributePairsRegex:EReg = new EReg("([a-zA-Z0-9_\\-]+)=['\"]([^'\"]+)['\"]", "ig");

	public var attributeCount(default, null):Int;
	// The HTML input. We need this to know what the generated HTML we're replacing is.
	public var html(default, null):String;

	private var attributes:Map<String, String> = new Map<String, String>();

	public function new(tagName:String, html:String)
	{
		this.html = html;
		// Haxe doesn't yet give us a way to get a map count, without iterating.
		// Iterating is O(n), and this is a fixed collection (won't change after
		// being created). So it's okay to self-count it this time.
		this.attributeCount = 0;

		// parse attributes
		var start = html.indexOf(tagName) + tagName.length;
		var stop = html.indexOf("/>");

		var attributesHtml = html.substring(start, stop);
		if (attributePairsRegex.match(attributesHtml))
		{
			// Iterate and extract all attributes. This is complicated because we don't
			// know how many attributes to expect, and Haxe doesn't expose a match count.
			// This is a horrible, terrible hack, but I don't have to worry about quotations
			// and funky parsing if I do this. Nobody puts @@ into their HTML attributes.
			var delimiter = "@@";
			var subst = '${delimiter}$1${delimiter}=${delimiter}$2${delimiter}';
			var matches = attributePairsRegex.replace(attributesHtml, subst); // eg. @@show-counts@@=@@true@@
			
			while (matches.indexOf(delimiter) > -1)
			{
				// Get the very next key/value pair. The magic number +2 is the "@@" delimiter length.
				var keyStart = matches.indexOf(delimiter) + 2;
				var keyEnd = matches.indexOf(delimiter, keyStart + 2);
				var valueStart = matches.indexOf(delimiter, keyEnd + 3) + 2;
				var valueEnd = matches.indexOf(delimiter, valueStart + 2);
				var key = matches.substring(keyStart, keyEnd);
				var value = matches.substring(valueStart, valueEnd);
				matches = matches.substring(valueEnd + 2);
				attributes.set(key, value);
				this.attributeCount += 1;
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
