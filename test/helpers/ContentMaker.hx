package test.helpers;

import butterfly.core.Page;
import sys.io.File;

class ContentMaker
{
  // Construct, parse, and return a page.
  public static function createPage(markdown:String, path:String)
  {
    var page:Page = new Page();
    File.saveContent(path, markdown);
    page.parse(path);
    return page;
  }
}
