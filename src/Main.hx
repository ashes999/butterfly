using StringTools;
using DateTools;

import butterfly.core.Post;
import butterfly.generator.AtomGenerator;
import butterfly.generator.HtmlGenerator;
import butterfly.html.FileWriter;
import butterfly.html.LayoutModifier;
import butterfly.io.FileSystem;

class Main {
  static public function main() : Void {
    new Main().run();
  }

  public function new() { }

  public function run() : Void {
    if (Sys.args().length != 1) {
      throw "Usage: neko Main.n <source directory>";
    }

    var projectDir = Sys.args()[0];
    trace("Using " + projectDir + " as project directory");
    FileSystem.ensureDirExists(projectDir);

    var binDir = projectDir + "/bin";
    if (sys.FileSystem.exists(binDir)) {
      // always clean/rebuild
      FileSystem.deleteDirRecursively(binDir);
      sys.FileSystem.createDirectory(binDir);
    }

    var srcDir = projectDir + "/src";
    FileSystem.ensureDirExists(srcDir);

    var configFile = '${srcDir}/config.json';
    if (!sys.FileSystem.exists(configFile)) {
      throw 'Config file ${configFile} is missing. Please add it as a JSON file with fields for siteName, siteUrl, authorName, and authorEmail.';
    }
    var config:Dynamic = haxe.Json.parse(sys.io.File.getContent(configFile));

    FileSystem.copyDirRecursively('${srcDir}/content', '${binDir}/content');

    var layoutFile = '${srcDir}/layout.html';

    // generate pages and tags first, because they appear in the header/layout
    var pages:Array<Post> = getPostsOrPages('${srcDir}/pages', true);
    var posts:Array<Post> = getPostsOrPages('${srcDir}/posts');

    if (posts.length > 0) {
      // sort by date, newest-first. Sorting by getTime() doesn't seem to work,
      // for some reason; sorting by the stringified dates (yyyy-mm-dd format) does.
      haxe.ds.ArraySort.sort(posts, function(a, b) {
        var x = a.createdOn.format("%Y-%m-%d");
        var y = b.createdOn.format("%Y-%m-%d");

        if (x < y ) { return 1; }
        else if (x > y) { return -1; }
        else { return 0; };

        //return result;
      });
    }
    var tags = new Array<String>();

    // Calculate tag counts
    for (post in posts) {
      for (tag in post.tags) {
        if (tags.indexOf(tag) == -1) {
          tags.push(tag);
        }
      }
    }

    var layoutHtml = new LayoutModifier(layoutFile, config, posts, pages).getHtml();
    if (layoutHtml.indexOf(HtmlGenerator.CONTENT_PLACEHOLDER) == -1) {
      throw "Layout HTML doesn't have the blog post placeholder in it: " + HtmlGenerator.CONTENT_PLACEHOLDER;
    }

    var generator = new HtmlGenerator(layoutHtml, posts, pages);
    var writer = new FileWriter(binDir);

    for (post in posts) {
      var html = generator.generatePostHtml(post, config);
      writer.writePost(post, html);
    }

    for (page in pages) {
      var html = generator.generatePostHtml(page, config);
      writer.writePost(page, html);
    }

    for (tag in tags) {
      var html = generator.generateTagPageHtml(tag, posts);
      writer.write('tag-${tag}.html', html);
    }

    this.generateIndexPage(config, srcDir, posts, pages, generator, writer);

    var atomXml = AtomGenerator.generate(posts, config);
    writer.write("atom.xml", atomXml);

    trace('Generated index page, ${pages.length} page(s), and ${posts.length} post(s).');
  }

  /**
  Generates the index.html (home page) file. By default, this uses the same
  layout as everything else, and fills in <butterfly-content /> with a list of
  posts, ordered chronologically descending.
  If homePageLayout is specified in the config file, that HTML file is used
  instead for the home page's layout.
  */
  public function generateIndexPage(config:ButterflyConfig, srcDir:String, posts:Array<Post>,
    pages:Array<Post>, generator:HtmlGenerator, writer:FileWriter) : Void
  {
    var indexPageHtml:String;
    if (config.homePageLayout != null) {
      var homePageLayoutFile:String = '${srcDir}/${config.homePageLayout}';
      var homePageHtml = new LayoutModifier(homePageLayoutFile, config, posts, pages, false).getHtml();
      var homePageGenerator:HtmlGenerator = new HtmlGenerator(homePageHtml, posts, pages);
      indexPageHtml = homePageGenerator.generateHomePage();
    } else {
      indexPageHtml = generator.generateHomePage();
    }
    writer.write("index.html", indexPageHtml);
  }

  private function getPostsOrPages(path:String, ?isPage:Bool = false) : Array<Post>
  {
    if (sys.FileSystem.exists(path) && sys.FileSystem.isDirectory(path)) {
      var filesAndDirs = sys.FileSystem.readDirectory(path);
      var posts = new Array<Post>();
      for (entry in filesAndDirs) {
        var relativePath = '${path}/${entry}';
        // Ignore .DS on Mac/OSX
        if (entry.indexOf(".DS") == -1 && !sys.FileSystem.isDirectory(relativePath)) {
          posts.push(Post.parse(relativePath, isPage));
        }
      }
      return posts;
    }
    return new Array<Post>();
  }
}
