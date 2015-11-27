package butterfly;
using StringTools;

class HtmlGenerator {
  private var layoutHtml:String;

  public function new(layoutFile:String)
  {
    this.layoutHtml = sys.io.File.getContent(layoutFile);
  }

  public function generateHtml(post:butterfly.Post) : String
  {
    var titleHtml = '<h2 class="blog-post-title">' + post.title + '</h2>';
    var postedOnHtml = '<p class="blog-post-meta">Posted ' + post.createdOn + '</p>';
    var finalHtml = "<div class='blog-post'>\n" + titleHtml + "\n" + postedOnHtml + "\n" + post.content + "</div>\n";
    return this.layoutHtml.replace('<div class="blog-post" />', finalHtml);
  }

}
