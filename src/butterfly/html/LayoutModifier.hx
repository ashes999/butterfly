package butterfly.html;

using StringTools;

// Transforms the layout in some way (eg. insert Atom XML link in <head>, etc.)
// based on configuration (eg. if you have a Google Analytics key defined in
// your config, getHtml() include analytics HTML in the head/body of the HTML).
class LayoutModifier
{
  private var layoutHtml:String;
  private static inline var GOOGLE_ANALYTICS_HTML_FILE:String = 'templates/googleAnalytics.html';
  private static inline var GOOGLE_ANALYTICS_IDENTIFIER = 'GOOGLE_ANALYTICS_ID';

  public function new(layoutFile:String, config:Dynamic)
  {
    if (!sys.FileSystem.exists(layoutFile)) {
      throw "Can't find layout file " + layoutFile;
    }

    var html = sys.io.File.getContent(layoutFile);

    html = addAtomLink(html, config);

    if (config.googleAnalyticsId != null) {
      html = addGoogleAnalytics(html, config.googleAnalyticsId);
    }

    this.layoutHtml = html;
  }

  // Returns the final, generated HTML that takes into account all of the required
  // changes (through the config).
  public function getHtml() : String
  {
    return this.layoutHtml;
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
}
