using StringTools;

class Main {
  static public function main() : Void {
    new Main().run();
  }

  public function new() { }

  public function run() : Void {
    if (Sys.args().length != 1) {
      errorAndExit("Usage: neko Main.n <source directory>");
    }

    var projectDir = Sys.args()[0];
    trace("Using " + projectDir + " as project directory");
    ensureDirExists(projectDir);

    var binDir = projectDir + "/bin";
    if (sys.FileSystem.exists(binDir)) {
      // always clean/rebuild
      deleteDirRecursively(binDir);
      sys.FileSystem.createDirectory(binDir);
    }

    var srcDir = projectDir + "/src";
    ensureDirExists(srcDir);

    copyDirRecursively(srcDir + '/content', binDir + '/content');

    var layoutFile = srcDir + "/layout.html";
    if (!sys.FileSystem.exists(layoutFile)) {
      errorAndExit("Can't find " + layoutFile);
    }

    // generate pages and tags first, because they appear in the header/layout
    var pages = getPosts(srcDir + '/pages');

    ensureDirExists(srcDir + '/posts');
    var posts = getPosts(srcDir + '/posts');
    // sort by date, newest-first
    posts.sort(function(a, b) {
      return Math.floor(b.createdOn.getTime() - a.createdOn.getTime());
    });

    var tagCounts = new Map<String, Int>();

    // Calculate tag counts
    for (post in posts) {
      for (tag in post.tags) {
        if (!tagCounts.exists(tag)) {
          tagCounts.set(tag, 0);
        }
        tagCounts.set(tag, tagCounts.get(tag) + 1);
      }
    }

    var generator = new butterfly.HtmlGenerator(layoutFile, pages, tagCounts);
    var writer = new butterfly.PostWriter(binDir);

    for (post in posts) {
      var html = generator.generatePostHtml(post);
      writer.writePost(post, html);
    }

    for (page in pages) {
      var html = generator.generatePostHtml(page);
      writer.writePost(page, html);
    }

    var indexPage = generator.generateHomePage(posts);
    writer.write("index.html", indexPage);

    trace("Generated index page and " + posts.length + " posts.");
  }

  private function errorAndExit(message:String) : Void
  {
    trace("Error: " + message);
    Sys.exit(1);
  }

  private function ensureDirExists(path:String) : Void
  {
    if (!sys.FileSystem.exists(path)) {
      errorAndExit(path + " doesn't exist");
    } else if (!sys.FileSystem.isDirectory(path)) {
      errorAndExit(path + " isn't a directory");
    }
  }

  private function copyDirRecursively(srcPath:String, destPath:String) : Void
  {
    if (!sys.FileSystem.exists(destPath)) {
      sys.FileSystem.createDirectory(destPath);
    }

    if (sys.FileSystem.exists(srcPath) && sys.FileSystem.isDirectory(srcPath))
    {
      var entries = sys.FileSystem.readDirectory(srcPath);
      for (entry in entries) {
        if (sys.FileSystem.isDirectory(srcPath + '/' + entry)) {
          sys.FileSystem.createDirectory(srcPath + '/' + entry);
          copyDirRecursively(srcPath + '/' + entry, destPath + '/' + entry);
        } else {
          sys.io.File.copy(srcPath + '/' + entry, destPath + '/' + entry);
        }
      }
    } else {
      throw srcPath + " doesn't exist or isn't a directory";
    }
  }

  private function deleteDirRecursively(path:String) : Void
  {
    if (sys.FileSystem.exists(path) && sys.FileSystem.isDirectory(path))
    {
      var entries = sys.FileSystem.readDirectory(path);
      for (entry in entries) {
        if (sys.FileSystem.isDirectory(path + '/' + entry)) {
          deleteDirRecursively(path + '/' + entry);
          sys.FileSystem.deleteDirectory(path + '/' + entry);
        } else {
          sys.FileSystem.deleteFile(path + '/' + entry);
        }
      }
    }
  }

  private function getPosts(path:String) : Array<butterfly.Post>
  {
    if (sys.FileSystem.exists(path) && sys.FileSystem.isDirectory(path)) {
      var filesAndDirs = sys.FileSystem.readDirectory(path);
      var posts = new Array<butterfly.Post>();
      for (entry in filesAndDirs) {
        var relativePath = path + "/" + entry;
        if (!sys.FileSystem.isDirectory(relativePath)) {
          posts.push(butterfly.Post.parse(relativePath));
        }
      }
      return posts;
    }
    return new Array<butterfly.Post>();
  }
}
