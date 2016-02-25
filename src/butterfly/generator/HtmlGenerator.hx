package butterfly.generator;

using StringTools;
using DateTools;

import butterfly.core.Page;
import butterfly.core.Post;
import butterfly.core.Content;
import ButterflyConfig;
import butterfly.html.TagFinder;
import butterfly.html.HtmlTag;

class HtmlGenerator {

  public static inline var CONTENT_PLACEHOLDER:String = '<butterfly-content />';

  private var layoutHtml:String;
  private var posts:Array<Post>;
  private var pages:Array<Page>;

  private static inline var TITLE_PLACEHOLDER:String = '<butterfly-title />';
  private static inline var POST_DATE_PLACEHOLDER:String = '<butterfly-post-date />';
  private static inline var COMMENTS_PLACEHOLDER:String = '<butterfly-comments />';

  private static inline var DISQUS_HTML_FILE:String = 'templates/disqus.html';
  private static inline var DISQUS_PAGE_URL:String = 'PAGE_URL';
  private static inline var DISQUS_PAGE_IDENTIFIER = 'PAGE_IDENTIFIER';

  public function new(layoutHtml:String, posts:Array<Post>, pages:Array<Page>)
  {
    this.layoutHtml = layoutHtml;
    this.posts = posts;
    this.pages = pages;
  }

  public function generatePageHtml(page:Page, config:ButterflyConfig) : String
  {
    var html:String = generateCommonHtml(page, config);
    var content = generateIntraSiteLinks(page.content);
    html = html.replace(CONTENT_PLACEHOLDER, content);
    return html;
  }

  /**
  Generates the HTML for a post, using values from config (like the site URL).
  Returns the fully-formed, final HTML (after rendering to Markdown, adding
  the HTML with the post's tags, etc.).
  */
  public function generatePostHtml(post:Post, config:ButterflyConfig) : String
  {
    var tagsHtml = "";
    var postDateHtml = "";

    // substitute in content
    if (post.tags.length > 0) {
      tagsHtml = "<p><strong>Tagged with:</strong> ";
      for (tag in post.tags) {
        tagsHtml += '${HtmlGenerator.tagLink(tag)}, ';
      }
      tagsHtml = tagsHtml.substr(0, tagsHtml.length - 2) + "</p>"; // trim final ", "
    }

    var html = generateCommonHtml(post, config);
    var content = generateIntraSiteLinks(post.content);

    // Substitute in posted-on date if the tag exists
    // If not, lump it into the content text.
    postDateHtml = '${post.createdOn.format("%Y-%m-%d")}';
    var postDateTag:HtmlTag = TagFinder.findTag(POST_DATE_PLACEHOLDER, html);
    if (postDateTag != null) {
      var prefix:String = postDateTag.attribute("prefix");
      var cssClass:String = ${postDateTag.attribute("class")}
      postDateHtml = '<p class="${cssClass}">${prefix}${postDateHtml}</p>';
      html = html.replace(postDateTag.html, postDateHtml);
    } else {
      postDateHtml = '<p>Posted on ${postDateHtml}</p>';
      content = '${postDateHtml}\n${content}';
    }

    var finalHtml = '${tagsHtml}\n${content}\n';
    finalHtml = html.replace(CONTENT_PLACEHOLDER, finalHtml);
    return finalHtml;
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

  public function generateHomePageHtml() : String
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

  /**
  Generates the HTML for a page, using values from config (like the site URL).
  Returns the fully-formed, final HTML (after rendering to Markdown).
  */
  private function generateCommonHtml(content:Content, config:ButterflyConfig):String
  {
    var finalContent = this.layoutHtml;

    // replace <butterfly-title /> with the title, if it exists
    finalContent = finalContent.replace(TITLE_PLACEHOLDER, content.title);

    // comments (disqus snippet)
    var disqusHtml = getDisqusHtml(content, config);
    finalContent = finalContent.replace(COMMENTS_PLACEHOLDER, disqusHtml);

    // prefix the post name to the title tag
    finalContent = finalContent.replace("<title>", '<title>${content.title} | ');
    return finalContent;
  }

  private function getDisqusHtml(content:Content, config:ButterflyConfig):String
  {
    var template = sys.io.File.getContent(DISQUS_HTML_FILE);
    var url = '${config.siteUrl}/${content.url}';
    template = template.replace(DISQUS_PAGE_URL, '"${url}"');
    template = template.replace(DISQUS_PAGE_IDENTIFIER, '"${content.id}"');
    return template;
  }

  private function generateIntraSiteLinks(content:String) : String
  {
    var toReturn = content;

    // Don't bother scanning if there are no links (syntax: [[title]])
    if (toReturn.indexOf("[[") > -1) {
      var titlesToUrls:Map<String, String> = new Map<String, String>();

      for (post in posts) {
        titlesToUrls.set(post.title, post.url);
      }
      for (page in pages) {
        titlesToUrls.set(page.title, page.url);
      }

      for (title in titlesToUrls.keys()) {
        var titlePlaceholder = new EReg('\\[\\[${title}]]', "i");
        if (titlePlaceholder.match(toReturn)) {
          var titleLink = '<a href="${titlesToUrls.get(title)}.html">${title}</a>';
          toReturn = titlePlaceholder.replace(toReturn, titleLink);
        } else {
        }
      }
    }

    return toReturn;
  }
}
