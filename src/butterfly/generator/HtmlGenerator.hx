package butterfly.generator;

using StringTools;
using DateTools;

import butterfly.core.Post;
import ButterflyConfig;
import butterfly.html.TagFinder;
import butterfly.html.HtmlTag;

class HtmlGenerator {

  public static inline var CONTENT_PLACEHOLDER:String = '<butterfly-content />';

  private var layoutHtml:String;
  private var posts:Array<Post>;
  private var pages:Array<Post>;

  private static inline var TITLE_PLACEHOLDER:String = '<butterfly-title />';
  private static inline var COMMENTS_PLACEHOLDER:String = '<butterfly-comments />';

  private static inline var DISQUS_HTML_FILE:String = 'templates/disqus.html';
  private static inline var DISQUS_PAGE_URL:String = 'PAGE_URL';
  private static inline var DISQUS_PAGE_IDENTIFIER = 'PAGE_IDENTIFIER';

  public function new(layoutHtml:String, posts:Array<Post>, pages:Array<Post>)
  {
    this.layoutHtml = layoutHtml;
    this.posts = posts;
    this.pages = pages;
  }

  /**
  Generates the HTML for a post, using values from config (like the site URL).
  Returns the fully-formed, final HTML (after rendering to Markdown, adding
  the HTML with the post's tags, etc.).
  */
  public function generatePostHtml(post:Post, config:ButterflyConfig) : String
  {
    // substitute in content
    var tagsHtml = "";
    if (post.tags.length > 0) {
      tagsHtml = "<p><strong>Tagged with:</strong> ";
      for (tag in post.tags) {
        tagsHtml += '${HtmlGenerator.tagLink(tag)}, ';
      }
      tagsHtml = tagsHtml.substr(0, tagsHtml.length - 2) + "</p>"; // trim final ", "
    }

    // posted-on date
    var postedOnHtml = "";
    if (post.createdOn != null) {
      postedOnHtml = '<p class="blog-post-meta">Posted ${post.createdOn.format("%Y-%m-%d")}</p>';
    }

    var finalContent = generateIntraSiteLinks(post.content);
    var finalHtml = '${tagsHtml}\n${postedOnHtml}\n${finalContent}\n';
    var toReturn = this.layoutHtml.replace(CONTENT_PLACEHOLDER, finalHtml);

    // replace <butterfly-title /> with the title, if it exists
    toReturn = toReturn.replace(TITLE_PLACEHOLDER, post.title);

    // comments (disqus snippet)
    var disqusHtml = getDisqusHtml(post, config);
    toReturn = toReturn.replace(COMMENTS_PLACEHOLDER, disqusHtml);

    // prefix the post name to the title tag
    toReturn = toReturn.replace("<title>", '<title>${post.title} | ');
    return toReturn;
  }

  public function generateIntraSiteLinks(content:String) : String
  {
    var toReturn = content;
    // Don't bother scanning if there are no links (syntax: [[title]])
    if (toReturn.indexOf("[[") > -1) {
      var postsAndPages = this.pages.concat(this.posts);
      for (c in postsAndPages) {
        var titlePlaceholder = new EReg('\\[\\[${c.title}]]', "i");
        if (titlePlaceholder.match(toReturn)) {
          var titleLink = '<a href="${c.url}.html">${c.title}</a>';
          toReturn = titlePlaceholder.replace(toReturn, titleLink);
        }
      }
    }

    return toReturn;
  }

  // Precondition: posts are sorted in the order we want to list them on the home page.
  public function generateTagPageHtml(tag:String, posts:Array<Post>):String
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
    return this.layoutHtml.replace(CONTENT_PLACEHOLDER, html);
  }

  public function generateHomePage() : String
  {
    var html = "<ul>";
    for (post in posts) {
      html += '<li><a href="${post.url}.html">${post.title}</a> (${post.createdOn.format("%Y-%m-%d")})</li>';
    }
    html += "</ul>";
    return this.layoutHtml.replace(CONTENT_PLACEHOLDER, html);
  }

  public static function tagLink(tag:String):String
  {
    return '<a href="tag-${tag}.html">${tag}</a>';
  }

  private function getDisqusHtml(post:Post, config:ButterflyConfig):String
  {
    var template = sys.io.File.getContent(DISQUS_HTML_FILE);
    var url = '${config.siteUrl}/${post.url}';
    template = template.replace(DISQUS_PAGE_URL, '"${url}"');
    template = template.replace(DISQUS_PAGE_IDENTIFIER, '"${post.id}"');
    return template;
  }
}
