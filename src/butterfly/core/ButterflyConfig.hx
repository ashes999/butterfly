package butterfly.core;

using noor.StringExtensions;

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
  
  public function new()
  {
      
  }
  
  public static function fromFile(configFile:String):ButterflyConfig
  {
    if (!sys.FileSystem.exists(configFile))
    {
      throw 'Config file ${configFile} is missing. Please add it as a JSON file with fields for siteName, siteUrl, and authorName.';
    }
    
    // You can't typecast the return value of haxe.Json.parse into a class.
    // It only works with typedefs. So, we have to use reflection to get/set values. 
    var raw = haxe.Json.parse(sys.io.File.getContent(configFile));
    var config:ButterflyConfig = new ButterflyConfig();
    var structsFields:Array<String> = Reflect.fields(raw);
    var classFields:Array<String> = Type.getInstanceFields(Type.getClass(config));
    
    for (field in structsFields)
    {
        if (classFields.indexOf(field) > -1)
        {
            var value:Dynamic = Reflect.field(raw, field);
            Reflect.setField(config, field, value);
        }
    }
    
    config.validate();
    return config;
  }
  
  public function validate()
  {
    if (this.siteName.isNullOrWhitespace())
    {
        throw 'siteName is a required config field, and it is empty';
    }
    if (this.siteUrl.isNullOrWhitespace())
    {
        throw 'siteUrl is a required config field, and it is empty';
    }
    if (this.authorName.isNullOrWhitespace())
    {
        throw 'authorName is a required config field, and it is empty';
    }
  }
}
