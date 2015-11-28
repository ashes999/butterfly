package butterfly;
using StringTools;
using DateTools;

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

  public function generatePostHtml(post:butterfly.Post) : String
  {
    var titleHtml = '<h2 class="blog-post-title">' + post.title + '</h2>';
    var postedOnHtml = '<p class="blog-post-meta">Posted ' + post.createdOn + '</p>';
    var finalHtml = postPlaceHolder + "\n" + titleHtml + "\n" + postedOnHtml + "\n" + post.content + "</div>\n";
    return this.layoutHtml.replace(postPlaceHolder, finalHtml);
  }

  public function generateHomePage(posts:Array<butterfly.Post>) : String
  {
    var html = "<ul>";
    for (post in posts) {
      html += '<li><a href="${post.url}.html">${post.title}</a> (Posted on ${post.createdOn.format("%Y-%m-%d")})</li>';
    }
    html += "</ul>";
    return this.layoutHtml.replace(postPlaceHolder, html);
  }
}
