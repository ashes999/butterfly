package butterfly.core;

import butterfly.extensions.StringExtensions;

class ButterflyConfig
{
  // These fields are required because atom generation is required
  public var siteName(default, default):String;
  public var siteUrl(default, default):String;
  public var authorName(default, default):String;
  // Optional fields
  public var authorEmail(default, default):String;
  public var googleAnalyticsId(default, default):String;
  public var homePageLayout(default, default):String;
  
  // Mostly used for testing; in production, don't create an empty config.
  public function new()
  {
      
  }
  
  public static function fromFile(configFile:String):ButterflyConfig
  {
    if (!sys.FileSystem.exists(configFile))
    {
      throw 'Config file ${configFile} is missing. Please add it as a JSON file with fields for siteName, siteUrl, and authorName.';
    }
    var config:ButterflyConfig = haxe.Json.parse(sys.io.File.getContent(configFile));
    if (StringExtensions.IsNullOrWhiteSpace(config.siteName))
    {
        throw 'siteName is a required field, and it is empty in ${configFile}';
    }
    if (StringExtensions.IsNullOrWhiteSpace(config.siteUrl))
    {
        throw 'siteUrl is a required field, and it is empty in ${configFile}';
    }
    if (StringExtensions.IsNullOrWhiteSpace(config.authorName))
    {
        throw 'authorName is a required field, and it is empty in ${configFile}';
    }
    return config;
  }
}
