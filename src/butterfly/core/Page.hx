package butterfly.core;

class Page extends Content
{
  // Yep, a page is nothing more than glorified Content right now.
  // This may change in the future. (Even if it doesn't, semantically, you could
  // argue that every Post is a Page; but that's harder to understand.)
  public static function parse(pathAndFileName:String) : Page
  {
    var page:Page = cast(Content.parse(pathAndFileName));
    return page;
  }

}
