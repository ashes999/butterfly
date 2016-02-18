package butterfly.generator;

import massive.munit.Assert;
import butterfly.generator.AtomGenerator;
import butterfly.core.Post;
import test.helpers.Factory;

class AtomGeneratorTest
{
	@Test
	public function generateUrlEncodesAngleBrackets()
	{
    var config = Factory.createButterflyConfig();
    config.siteName = "Haxe > Stuff";
    var post = new Post();
    post.title = "Use of <b> is deprecated";
    post.content = "The <b> (bold) tag is long deprecated.";
    var posts = [post];
    var actual = AtomGenerator.generate(posts, config);

    // siteName encoding
    Assert.isTrue(actual.indexOf("<title>Haxe &gt; Stuff") > -1);
    Assert.isTrue(actual.indexOf("<title>Use of &lt;b&gt;") > -1);
    Assert.isTrue(actual.indexOf("<summary>Use of &lt;b&gt;") > -1);

    var contentStart = actual.indexOf('<content');
    var contentEnd = actual.indexOf('</content>');
    var content = actual.substring(contentStart, contentEnd);
    Assert.isTrue(content.indexOf('The &lt;b&gt;') > -1);
  }

  @Test
  public function generateIncludesSiteNameSiteUrlAuthorNameAndEmailFromConfig()
  {
    var config = Factory.createButterflyConfig();
    config.siteName = "Haxe Blog";
    config.siteUrl = "http://awesome.haxe.com/blog";
    config.authorName = "Haxerman";
    config.authorEmail = "haxerman@haxe.com";

    // Author info only appears with posts
    var post = new Post();
    post.title = "Hello Blog";
    post.content = "Hello, blog!";
    var posts = [post];

    var actual = AtomGenerator.generate(posts, config);

    Assert.isTrue(actual.indexOf('<title>${config.siteName}</title>') > -1);
    Assert.isTrue(actual.indexOf('<link href="${config.siteUrl}"') > -1);
    Assert.isTrue(actual.indexOf('<name>${config.authorName}</name>') > -1);
    Assert.isTrue(actual.indexOf('<email>${config.authorEmail}</email>') > -1);
  }

  @Test
  public function generateExcludesAuthorEmailIfNotSetInConfig()
  {
    var config = Factory.createButterflyConfig();
    config.siteName = "Haxe Blog";
    config.siteUrl = "http://awesome.haxe.com/blog";
    config.authorName = "Haxerman";

    // Author info only appears with posts
    var post = new Post();
    post.title = "Hello Blog";
    post.content = "Hello, blog!";
    var posts = [post];

    var actual = AtomGenerator.generate(posts, config);

    Assert.isTrue(actual.indexOf('<title>${config.siteName}</title>') > -1);
    Assert.isTrue(actual.indexOf('<link href="${config.siteUrl}"') > -1);
    Assert.isTrue(actual.indexOf('<name>${config.authorName}</name>') > -1);
    Assert.isTrue(actual.indexOf('<email>${config.authorEmail}</email>') == -1);
  }
}
