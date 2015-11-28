package butterfly;
using StringTools;
using DateTools;

class HtmlGenerator {

  private var layoutHtml:String;
  private var postPlaceHolder:String = '<butterfly-content />';
  private var pages:Array<butterfly.Post>;
  
  public function new(layoutFile:String, pages:Array<butterfly.Post>)
  {
    this.layoutHtml = sys.io.File.getContent(layoutFile);
    if (this.layoutHtml.indexOf(postPlaceHolder) == -1) {
      throw layoutFile + " doesn't have the blog post placeholder in it: " + postPlaceHolder;
    }

    this.pages = pages;
  }

  public function generatePostHtml(post:butterfly.Post) : String
  {
    // substitute in content
    var titleHtml = '<h2 class="blog-post-title">' + post.title + '</h2>';
    var postedOnHtml = '<p class="blog-post-meta">Posted ' + post.createdOn.format("%Y-%m-%d") + '</p>';
    var finalHtml = titleHtml + "\n" + postedOnHtml + "\n" + post.content + "\n";
    var toReturn = this.layoutHtml.replace(postPlaceHolder, finalHtml);

    // prefix the post name to the title tag
    toReturn = toReturn.replace("<title>", '<title>${post.title} | ');
    return toReturn;
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
