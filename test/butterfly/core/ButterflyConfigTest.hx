package butterfly.core;

import butterfly.core.ButterflyConfig;
import massive.munit.Assert;
import sys.io.File;
import sys.FileSystem;
import test.helpers.Assert2;

class ButterflyConfigTest
{
  @Test
  public function validateThrowsIfSiteNameIsNullOrEmpty()
  {
    var config:ButterflyConfig = new ButterflyConfig();
    config.siteName = null;
    var message:String = Assert2.throws(function()
    {
        config.validate();
    });
    Assert.isTrue(message.indexOf("siteName") > -1);    
  }
  
  @Test
  public function validateThrowsIfSiteUrlIsNullOrEmpty()
  {
    var config:ButterflyConfig = new ButterflyConfig();
    config.siteName = "Dummy Site";
    config.siteUrl = "";
    var message:String = Assert2.throws(function()
    {
        config.validate();
    });
    Assert.isTrue(message.indexOf("siteUrl") > -1);    
  }
  
  @Test
  public function validateThrowsIfAuthorNameIsNullOrEmpty()
  {
    var config:ButterflyConfig = new ButterflyConfig();
    config.siteName = "Dummy Site";
    config.siteUrl = "http://dummy.com";
    var message:String = Assert2.throws(function()
    {
        config.validate();
    });
    Assert.isTrue(message.indexOf("authorName") > -1);    
  }
}
