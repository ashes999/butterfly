class Main {
  static public function main() : Void {
    new Main().run();
  }

  public function new() {

  }

  public function run() : Void {
    if (Sys.args().length != 1) {
      errorAndExit("Usage: neko Main.n <source directory>");
    }

    var srcDir = Sys.args()[0];
    trace("Using " + srcDir + " as source directory ...");

    if (!sys.FileSystem.exists(srcDir) || !sys.FileSystem.isDirectory(srcDir)) {
      errorAndExit(srcDir + " doesn't exist or isn't a directory");
    }

    var binDir = srcDir + "/bin";
    if (!sys.FileSystem.exists(binDir)) {
      sys.FileSystem.createDirectory(binDir);
      trace("Created " + binDir);
    }

    if (!sys.FileSystem.exists(srcDir + "/src/layout.html")) {
      errorAndExit("Can't find " + srcDir + "/src/layout.html");
    }

    var postsDir = srcDir + '/posts';
    if (!sys.FileSystem.exists(postsDir) || !sys.FileSystem.isDirectory(postsDir)) {
      errorAndExit(postsDir + " doesn't exist or isn't a directory");
    }
  }

  private function errorAndExit(message:String) : Void {
    trace("Error: " + message);
    Sys.exit(1);
  }
}
