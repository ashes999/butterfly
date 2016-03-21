package test.helpers;

import sys.io.File;

import butterfly.core.Page;
import butterfly.core.Post;
import butterfly.generator.HtmlGenerator;

// static class. Doesn't meet the S in SOLID (it can change for multiple reasons).
// Provides an easy way to construct stuff. Maybe we should refactor these classes
// so that they have simpler constructors? Maybe we want dependency injection?
class Factory
{
  public static function createHtmlGenerator(layoutHtml:String = "<butterfly-pages /><butterfly-content /><butterfly-tags />")
  : HtmlGenerator
  {
    // Minimum set of tags we need for Butterfly to work.
    // butterfly-tags generates a warning if not present (it's optional)
    var toReturn = new HtmlGenerator(layoutHtml, new Array<Post>(), new Array<Page>());
    return toReturn;
  }

  // Construct, parse, and return a page.
  public static function createPage(markdown:String, path:String)
  {
    var page:Page = new Page();
    File.saveContent(path, markdown);
    page.parse(path);
    return page;
  }

  // Construct, parse, and return a post.
  public static function createPost(markdown:String, path:String)
  {
    var post:Post = new Post();
    File.saveContent(path, markdown);
    post.parse(path);
    return post;
  }
  
  // Creates a layout file. Has a sensible default HTML/filename. Returns the
  // fully-qualified file name.
  public static  function createLayoutFile(fileName:String = 'layout.html',
    html:String = "<html><head></head><body><butterfly-pages /><!-- Placeholder --></body></html>") : String
  {
    sys.io.File.saveContent(fileName, html);
    return fileName;
  }
}
