class Main {
  static public function main() : Void {
    new Main().run();
  }

  public function new() {

  }

  public function run() : Void {
    if (Sys.args().length != 1) {
      errorOut("Usage: neko Main.n <source directory>");
    }

    var srcDir = Sys.args()[0];
    trace("Using " + srcDir + " as source directory ...");

    if (!sys.FileSystem.exists(srcDir)) {
      errorOut(srcDir + " doesn't exist");
    }
    if (!sys.FileSystem.isDirectory(srcDir)) {
      errorOut(srcDir + " isn't a directory");
    }

    var binDir = srcDir + "/bin";
    if (!sys.FileSystem.exists(binDir)) {
      sys.FileSystem.createDirectory(binDir);
      trace("Created " + binDir);
    }
  }

  private function errorOut(message:String) : Void {
    trace("Error: " + message);
    Sys.exit(1);
  }
}
