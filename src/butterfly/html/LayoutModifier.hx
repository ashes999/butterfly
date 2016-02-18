package butterfly.html;

import butterfly.core.Post;
import butterfly.generator.HtmlGenerator;

using StringTools;

// Transforms the layout in some way (eg. insert Atom XML link in <head>, etc.)
// based on configuration (eg. if you have a Google Analytics key defined in
// your config, getHtml() include analytics HTML in the head/body of the HTML).
class LayoutModifier
{
  private var layoutHtml:String;

  private static inline var PAGES_LINKS_PLACEHOLDER:String = '<butterfly-pages />';
  private static inline var TAGS_PLACEHOLDER:String = '<butterfly-tags />';
  private static inline var TAGS_COUNTS_OPTION:String = 'show-counts';

  private static inline var GOOGLE_ANALYTICS_HTML_FILE:String = 'templates/googleAnalytics.html';
  private static inline var GOOGLE_ANALYTICS_IDENTIFIER = 'GOOGLE_ANALYTICS_ID';

  private var postsAndPages:Array<Post>; // all pages and posts

  public function new(layoutFile:String, config:ButterflyConfig, posts:Array<Post>, pages:Array<Post>)
  {
    if (!sys.FileSystem.exists(layoutFile)) {
      throw "Can't find layout file " + layoutFile;
    }

    this.postsAndPages = pages.concat(posts);

    var html:String = sys.io.File.getContent(layoutFile);

    var pagesTag:HtmlTag = TagFinder.findTag(PAGES_LINKS_PLACEHOLDER, html);
    if (pagesTag == null) {
      throw 'Layout file ${layoutFile} does not contain the tag to list pages: ${PAGES_LINKS_PLACEHOLDER}';
    }

    var pagesHtml:String = this.generatePagesLinksHtml(pagesTag, pages);
    html = html.replace(pagesTag.html, pagesHtml);

    var tagsHtml = this.generateTagsHtml(html);
    // Replace it. The tag may have options.
    var butterflyTag:HtmlTag = TagFinder.findTag(TAGS_PLACEHOLDER, html);
    if (butterflyTag != null)
    {
      html = html.replace(butterflyTag.html, tagsHtml);
    }

    html = addAtomLink(html, config);

    if (config.googleAnalyticsId != null) {
      html = addGoogleAnalytics(html, config.googleAnalyticsId);
    }

    html = substituteVariables(html, config);
    this.layoutHtml = html;
  }

  /**
  Substitues any variables defined in the layout with their values from config.json.
  eg. $siteName is replaced with the value of the config.json property
  Returns the modified (after-substitution) HTML.
  */
  private function substituteVariables(html:String, config:ButterflyConfig) : String
  {
    var toReturn:String = html;

    var fields:Array<String> = Reflect.fields(config);
    for (field in fields) {
      var value:String = Reflect.field(config, field);
      // If the property is "siteName", replace ""$siteName" with the value
      toReturn = toReturn.replace('$$$field', value);
    }

    return toReturn;
  }

  // Returns the final, generated HTML that takes into account all of the required
  // changes (through the config).
  public function getHtml() : String
  {
    return this.layoutHtml;
  }

  private function generatePagesLinksHtml(pagesTag:HtmlTag, pages:Array<Post>) : String
  {
    var linkAttributes:String = pagesTag.attribute("link-attributes");
    var linkPrefix:String = pagesTag.attribute("link-prefix");
    var linkSuffix:String = pagesTag.attribute("link-suffix");

    var html = "";

    for (page in pages) {
     html += '${linkPrefix}<a ${linkAttributes} href="${page.url}.html">${page.title}</a>${linkSuffix}';
    }

    return html;
  }

  private function generateTagsHtml(html:String) : String
  {
    var butterflyTag:HtmlTag = TagFinder.findTag(TAGS_PLACEHOLDER, html);
    if (butterflyTag != null) {
      var tagCounts:Map<String, Int> = new Map<String, Int>();

      // Calculate tag counts. We need the list of tags even if we don't show counts.
      for (post in this.postsAndPages) {
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
        html += '<li>${HtmlGenerator.tagLink(tag)}';
        if (butterflyTag.attribute(TAGS_COUNTS_OPTION) != "") {
          html += ' (${tagCounts.get(tag)})';
        }
        html += '</li>\n';
      }
      html += "</ul>";
      return html;
    } else {
      // Laytout doesn't include tags HTML.
      return "";
    }
  }

  private function addGoogleAnalytics(html:String, analyticsId:String) : String
  {
    // Easiest way to insert it into the body is to append it to <body>
    var analyticsHtml = sys.io.File.getContent(GOOGLE_ANALYTICS_HTML_FILE);
    if (analyticsHtml.indexOf(GOOGLE_ANALYTICS_IDENTIFIER) == -1) {
      throw 'Analytics HTML template does not have the replaceable identifier ${GOOGLE_ANALYTICS_IDENTIFIER} in it.';
    }
    var analyticsHtml = analyticsHtml.replace(GOOGLE_ANALYTICS_IDENTIFIER, analyticsId);
    return html.replace("<body>", '<body>${analyticsHtml}');
  }

  private function addAtomLink(html:String, config:Dynamic) : String
  {
    var toReturn:String = html;
    var atomLink = '<link type="application/atom+xml" title="${config.siteName}" href="${config.siteUrl}/atom.xml" rel="alternate" />';
    toReturn = toReturn.replace("</head>", '${atomLink}\r\n</head>');
    return toReturn;
  }

  // Get an array of keys sorted alphabetically.
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
