package butterfly;
using StringTools;
using DateTools;

class HtmlGenerator {

  private var layoutHtml:String;
  private static inline var COTENT_PLACEHOLDER:String = '<butterfly-content />';
  private static inline var PAGES_LINKS_PLACEHOLDER:String = '<butterfly-pages />';

  public function new(layoutFile:String, pages:Array<butterfly.Post>)
  {
    this.layoutHtml = sys.io.File.getContent(layoutFile);
    if (this.layoutHtml.indexOf(COTENT_PLACEHOLDER) == -1) {
      throw layoutFile + " doesn't have the blog post placeholder in it: " + COTENT_PLACEHOLDER;
    }

    var pagesHtml = this.generatePagesLinksHtml(pages);
    this.layoutHtml = this.layoutHtml.replace(PAGES_LINKS_PLACEHOLDER, pagesHtml);
  }

  public function generatePostHtml(post:butterfly.Post) : String
  {
    // substitute in content

    var titleHtml = '<h2 class="blog-post-title">' + post.title + '</h2>';
    var tagsHtml = "";
    if (post.tags.length > 0) {
      tagsHtml = "<p><strong>Tagged with:</strong> ";
      for (tag in post.tags) {
        tagsHtml += '${tag}, ';
      }
      tagsHtml = tagsHtml.substr(0, tagsHtml.length - 2) + "</p>"; // trim final ", "
    }
    var postedOnHtml = '<p class="blog-post-meta">Posted ${post.createdOn.format("%Y-%m-%d")}</p>';
    var finalHtml = '${titleHtml}\n${tagsHtml}\n${postedOnHtml}\n${post.content}\n';
    var toReturn = this.layoutHtml.replace(COTENT_PLACEHOLDER, finalHtml);

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
    return this.layoutHtml.replace(COTENT_PLACEHOLDER, html);
  }

  private function generatePagesLinksHtml(pages:Array<butterfly.Post>) : String
  {
    var html = "";
    for (page in pages) {
      html += '<a class="blog-nav-item" href="${page.url}.html">${page.title}</a>';
    }
    return html;
  }
}
