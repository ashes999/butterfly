package butterfly.html;

import butterfly.html.HtmlTag;

using StringTools;

// Static class
class TagFinder
{
  /**
  Specify a tag name (eg. "butterfly-pages"). If the tag exists in the HTML, this
  function returns an HtmlTag object. This includes the entire (raw, string) tag,
  and all attributes in a map. If the tag isn't in the HTML, this function returns
  null. You can send a tag instead of a tag name (eg. <img />).
  Tags are case-insensitive.
  Tags must be self-enclosed (eg. <img />)
  */
  public static function findTag(tagName:String, html:String) : HtmlTag
  {
    tagName = tagName.replace("<", "").replace(">", "").replace("/", "");
    var start:Int = html.indexOf('<${tagName}');
    if (start > -1) {
        var stop:Int = html.indexOf("/>", start);
        var tagHtml = html.substring(start, stop + 2); // 2 = length of "/>"
        return new HtmlTag(tagName, tagHtml);
    } else {
      return null;
    }
  }
}
