package butterfly;
using StringTools;
using DateTools;

class HtmlGenerator {

  private var layoutHtml:String;
  private static inline var COTENT_PLACEHOLDER:String = '<butterfly-content />';
  private static inline var PAGES_LINKS_PLACEHOLDER:String = '<butterfly-pages />';
  private static inline var TAG_COUNT_PLACEHOLDER:String = '<butterfly-tags />';


  public function new(layoutFile:String, pages:Array<butterfly.Post>, tagCounts:Map<String, Int>)
  {
    this.layoutHtml = sys.io.File.getContent(layoutFile);
    if (this.layoutHtml.indexOf(COTENT_PLACEHOLDER) == -1) {
      throw layoutFile + " doesn't have the blog post placeholder in it: " + COTENT_PLACEHOLDER;
    }

    var pagesHtml = this.generatePagesLinksHtml(pages);
    this.layoutHtml = this.layoutHtml.replace(PAGES_LINKS_PLACEHOLDER, pagesHtml);

    var tagCountHtml = this.generateTagCountHtml(tagCounts);
    this.layoutHtml = this.layoutHtml.replace(TAG_COUNT_PLACEHOLDER, tagCountHtml);
  }

  public function generatePostHtml(post:butterfly.Post) : String
  {
    // substitute in content
    var titleHtml = '<h2 class="blog-post-title">' + post.title + '</h2>';
    var tagsHtml = "";
    if (post.tags.length > 0) {
      tagsHtml = "<p><strong>Tagged with:</strong> ";
      for (tag in post.tags) {
        tagsHtml += '<a href="${tagLink(tag)}">${tag}</a>, ';
      }
      tagsHtml = tagsHtml.substr(0, tagsHtml.length - 2) + "</p>"; // trim final ", "
    }
    var postedOnHtml = "";
    if (post.createdOn != null) {
      postedOnHtml = '<p class="blog-post-meta">Posted ${post.createdOn.format("%Y-%m-%d")}</p>';
    }
    var finalHtml = '${titleHtml}\n${tagsHtml}\n${postedOnHtml}\n${post.content}\n';
    var toReturn = this.layoutHtml.replace(COTENT_PLACEHOLDER, finalHtml);

    // prefix the post name to the title tag
    toReturn = toReturn.replace("<title>", '<title>${post.title} | ');
    return toReturn;
  }

  // Precondition: posts are sorted in the order we want to list them.
  public function generateTagPageHtml(tag:String, posts:Array<butterfly.Post>):String
  {
    var count = 0;
    var html = "<ul>";
    for (post in posts) {
      if (post.tags.indexOf(tag) > -1) {
        html += '<li><a href="${post.url}.html">${post.title}</a></li>';
        count++;
      }
    }
    html += "</ul>";
    html = '<p>${count} posts tagged with ${tag}:</p>\n${html}';
    return this.layoutHtml.replace(COTENT_PLACEHOLDER, html);
  }

  public function generateHomePage(posts:Array<butterfly.Post>) : String
  {
    var html = "<ul>";
    for (post in posts) {
      html += '<li><a href="${post.url}.html">${post.title}</a> (${post.createdOn.format("%Y-%m-%d")})</li>';
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

  private function generateTagCountHtml(tagCounts:Map<String, Int>) : String
  {
    var tags = sortKeys(tagCounts);
    var html = "<ul>";
    for (tag in tags) {
      html += '<li><a href="${tagLink(tag)}">${tag}</a> (${tagCounts.get(tag)})</li>\n';
    }
    html += "</ul>";
    return html;
  }

  private function tagLink(tag:String):String
  {
    return 'tag-${tag}.html';
  }

  private function sortKeys(map:haxe.ds.StringMap<Dynamic>) : Array<String>
  {
    // Sort tags by name. Collect them into an array, sort that, et viola.
    var keys = new Array<String>();

    var mapKeys = map.keys();
    while (mapKeys.hasNext()) {
      var next = mapKeys.next();
      if (keys.indexOf(next) == -1) {
        keys.push(next);
      }
    }

    keys.sort(function(a:String, b:String):Int {
      a = a.toUpperCase();
      b = b.toUpperCase();

      if (a < b) {
        return -1;
      }
      else if (a > b) {
        return 1;
      } else {
        return 0;
      }
    });

    return keys;
  }
}
