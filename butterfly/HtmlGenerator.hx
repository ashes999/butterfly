package butterfly;
using StringTools;

class HtmlGenerator {

  private var layoutHtml:String;
  private var postPlaceHolder:String = '<div class="blog-post" />';

  public function new(layoutFile:String)
  {
    this.layoutHtml = sys.io.File.getContent(layoutFile);
    if (this.layoutHtml.indexOf(postPlaceHolder) == -1) {
      throw layoutFile + " doesn't have the blog post placeholder in it: " + postPlaceHolder;
    }
  }

  public function generateHtml(post:butterfly.Post) : String
  {
    var titleHtml = '<h2 class="blog-post-title">' + post.title + '</h2>';
    var postedOnHtml = '<p class="blog-post-meta">Posted ' + post.createdOn + '</p>';
    var finalHtml = postPlaceHolder + "\n" + titleHtml + "\n" + postedOnHtml + "\n" + post.content + "</div>\n";
    return this.layoutHtml.replace(postPlaceHolder, finalHtml);
  }

}
