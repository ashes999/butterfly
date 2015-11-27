package butterfly;
using StringTools;

class Post {
  public var title(default, null) : String;
  public var content(default, null) : String;

  public function new() {
  }

  // fileName doesn't include any path characters
  public static function parse(fileName:String, content:String) {
    var post = new Post();
    post.title = getTitleFrom(fileName);
    post.content = content;
    return post;
  }

  private static function getTitleFrom(fileName:String) {
    var name = fileName.substr(0, fileName.toUpperCase().lastIndexOf('.MD'));
    var words:Array<String> = name.split('-');

    var toReturn = "";
    for (word in words) {
      // TODO: filter out stop-words properly instead of guessing by length
      // Capitalizes the first letter for non-stop-words
      if (word.length > 3) {
        word = word.charAt(0).toUpperCase() + word.substr(1);
      }
      toReturn += word + " ";
    }
    return toReturn.trim();
  }
}
