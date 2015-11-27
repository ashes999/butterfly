package butterfly;

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
    trace(postedOnHtml);
    return this.layoutHtml;
  }

}
