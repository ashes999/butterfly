class Main {
  static public function main():Void {
    if (Sys.args().length != 1) {
      trace("Usage: neko Main.n <source directory>");
    } else {
      trace("Using " + Sys.args()[0] + " as source directory ...");
    }
  }
}
