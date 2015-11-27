package butterfly;

class Post {
  public function new() {

  }

  public static function parse(fileName:String) {
    if (!sys.FileSystem.exists(fileName)) {
      throw "Can't post file for " + fileName + " because it doesn't exist.";
    } else {
      return new Post();
    }
  }
}
