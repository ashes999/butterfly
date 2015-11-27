package butterfly;

class Post {
  public var title(default, null) : String;
  public var content(default, null) : String;

  public function new() {
  }

  public static function parse(fileName:String, content:String) {
    var post = new Post();
    post.title = fileName;
    post.content = content;
    return post;
  }
}
