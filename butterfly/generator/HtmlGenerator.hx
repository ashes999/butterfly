package butterfly.generator;

using StringTools;
using DateTools;
using butterfly.core.Post;

class HtmlGenerator {

  private var layoutHtml:String;
  private static inline var COTENT_PLACEHOLDER:String = '<butterfly-content />';
  private static inline var PAGES_LINKS_PLACEHOLDER:String = '<butterfly-pages />';
  private static inline var TAGS_PLACEHOLDER:String = '<butterfly-tags />';
  private static inline var TAGS_COUNTS_OPTION:String = 'show-counts';
  private static inline var COMMENTS_PLACEHOLDER:String = '<butterfly-comments />';
  private static inline var DISQUS_HTML_FILE:String = 'templates/disqus.html';
  private static inline var DISQUS_PAGE_URL:String = 'PAGE_URL';
  private static inline var DISQUS_PAGE_IDENTIFIER = 'PAGE_IDENTIFIER';

  private var allContent:Array<Post>;

  public function new(layoutHtml:String, posts:Array<Post>, pages:Array<Post>)
  {
    this.layoutHtml = layoutHtml;
    if (this.layoutHtml.indexOf(COTENT_PLACEHOLDER) == -1) {
      throw "Layout HTML doesn't have the blog post placeholder in it: " + COTENT_PLACEHOLDER;
    }

    // Pages first so if both a post and page share a title, the page wins.
    this.allContent = pages.concat(posts);

    var pagesHtml = this.generatePagesLinksHtml(pages);
    this.layoutHtml = this.layoutHtml.replace(PAGES_LINKS_PLACEHOLDER, pagesHtml);

    var tagsHtml = this.generateTagsHtml();
    // Replace it. The tag may have options.
    var butterflyTagHtml:String = this.getButterflyTagHtml();
    if (butterflyTagHtml != "") {
      this.layoutHtml = this.layoutHtml.replace(butterflyTagHtml, tagsHtml);
    }
  }

  public function generatePostHtml(post:Post, config:Dynamic) : String
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

    // posted-on date
    var postedOnHtml = "";
    if (post.createdOn != null) {
      postedOnHtml = '<p class="blog-post-meta">Posted ${post.createdOn.format("%Y-%m-%d")}</p>';
    }

    var finalContent = generateIntraSiteLinks(post.content);
    var finalHtml = '${titleHtml}\n${tagsHtml}\n${postedOnHtml}\n${finalContent}\n';
    var toReturn = this.layoutHtml.replace(COTENT_PLACEHOLDER, finalHtml);

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
      for (c in allContent) {
        var titlePlaceholder = new EReg('\\[\\[${c.title}]]', "i");
        if (titlePlaceholder.match(toReturn)) {
          var titleLink = '<a href="${c.url}.html">${c.title}</a>';
          toReturn = titlePlaceholder.replace(toReturn, titleLink);
        }
      }
    }

    return toReturn;
  }

  // Precondition: posts are sorted in the order we want to list them.
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
    return this.layoutHtml.replace(COTENT_PLACEHOLDER, html);
  }

  public function generateHomePage(posts:Array<Post>) : String
  {
    var html = "<ul>";
    for (post in posts) {
      html += '<li><a href="${post.url}.html">${post.title}</a> (${post.createdOn.format("%Y-%m-%d")})</li>';
    }
    html += "</ul>";
    return this.layoutHtml.replace(COTENT_PLACEHOLDER, html);
  }

  private function generatePagesLinksHtml(pages:Array<Post>) : String
  {
    var html = "";
    for (page in pages) {
      html += '<a class="blog-nav-item" href="${page.url}.html">${page.title}</a>';
    }
    return html;
  }

  private function generateTagsHtml() : String
  {
    var butterflyTagHtml:String = this.getButterflyTagHtml();
    if (butterflyTagHtml != "") {
      var tagCounts:Map<String, Int> = new Map<String, Int>();

      // Calculate tag counts. We need the list of tags even if we don't show counts.
      for (post in this.allContent) {
        for (tag in post.tags) {
          if (!tagCounts.exists(tag)) {
            tagCounts.set(tag, 0);
          }
          tagCounts.set(tag, tagCounts.get(tag) + 1);
        }
      }

      var tags = sortKeys(tagCounts);
      var html = "<ul>";
      for (tag in tags) {
        html += '<li><a href="${tagLink(tag)}">${tag}</a>';
        if (butterflyTagHtml.indexOf(TAGS_COUNTS_OPTION) > -1) {
          html += ' (${tagCounts.get(tag)})';
        }
        html += '</li>\n';
      }
      html += "</ul>";
      return html;
    } else {
      // Laytout doesn't include tags HTML.
      trace("Warning: Layout doesn't contain <butterfly-tags /> element!");
      return "";
    }
  }

  private function getDisqusHtml(post:Post, config:Dynamic):String
  {
    var template = sys.io.File.getContent(DISQUS_HTML_FILE);
    var url = '${config.siteUrl}/${post.url}';
    template = template.replace(DISQUS_PAGE_URL, '"${url}"');
    template = template.replace(DISQUS_PAGE_IDENTIFIER, '"${post.id}"');
    return template;
  }

  private function tagLink(tag:String):String
  {
    return 'tag-${tag}.html';
  }

  // Get the <butterfly-tags> tag, including any options (eg. show-counts).
  // If the tag isn't present in our layout, we return an empty string.
  private function getButterflyTagHtml():String
  {
    var startTag:String = TAGS_PLACEHOLDER.substring(0, TAGS_PLACEHOLDER.indexOf('/>'));
    var startIndex:Int = this.layoutHtml.indexOf(startTag);
    if (startIndex > -1) {
      // Layout includes tags HTML.
      var stopIndex:Int = this.layoutHtml.indexOf('/>', startIndex);
      var butterflyTagHtml:String = this.layoutHtml.substring(startIndex, stopIndex + 2);
      return butterflyTagHtml;
    } else {
      // Tag is absent from layout
      return "";
    }
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
