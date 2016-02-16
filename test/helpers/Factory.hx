package test.helpers;

import butterfly.core.Post;
import butterfly.generator.HtmlGenerator;

// static class. Doesn't meet the S in SOLID (it can change for multiple reasons).
// Provides an easy way to construct stuff. Maybe we should refactor these classes
// so that they have simpler constructors? Maybe we want dependency injection?
class Factory
{
  public static function createHtmlGenerator() : HtmlGenerator
  {
    // Minimum set of tags we need for Butterfly to work.
    // butterfly-tags generates a warning if not present (it's optional)
    var layoutHtml = "<butterfly-pages /><butterfly-content /><butterfly-tags />";
    var emptyList = new Array<Post>();
    var toReturn = new HtmlGenerator(layoutHtml, emptyList, emptyList);
    return toReturn;
  }

  public static function createButterflyConfig() : ButterflyConfig
  {
    // Typedefs are painful to work with. We have to have all fields here,
    // even if they're @optional.
    return {
      "siteName": "",
      "siteUrl": "",
      "authorName": "",
      "authorEmail": "",

      // optional fields
      "googleAnalyticsId": "",
      "linkPrefix": "",
      "linkSuffix": "",
      "linkAttributes": "",
    }
  }
}
