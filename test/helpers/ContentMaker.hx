package test.helpers;

import butterfly.core.Page;
import butterfly.core.Post;
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

  // Construct, parse, and return a post.
  public static function createPost(markdown:String, path:String)
  {
    var post:Post = new Post();
    File.saveContent(path, markdown);
    post.parse(path);
    return post;
  }
}
