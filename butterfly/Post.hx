package butterfly;
using StringTools;

class Post {
  public var title(default, null) : String;
  public var content(default, null) : String;
  public var url(default, null) : String;
  public var createdOn(default, null) : Date;
  public var tags(default, null) : Array<String>;

  private static var tagRegex = ~/^tags: ([\w\s,\-_]+)\n/i;

  public function new() {
  }

  // fileName doesn't include any path characters
  public static function parse(pathAndFileName:String) : Post
  {
    var fileName = pathAndFileName.substr(pathAndFileName.lastIndexOf('/') + 1);
    var post = new Post();
    post.title = getTitle(fileName);
    post.url = getUrl(fileName);
    post.createdOn = sys.FileSystem.stat(pathAndFileName).ctime;
    post.tags = getTags(pathAndFileName);
    post.content = getContent(pathAndFileName);
    return post;
  }

  private static function getTitle(fileName:String) : String
  {
    var url = getUrl(fileName);
    var words:Array<String> = url.split('-');

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

  private static function getContent(pathAndFileName:String) : String
  {
    var markdown = sys.io.File.getContent(pathAndFileName);
    // Remove tags
    markdown = tagRegex.replace(markdown, "");
    var html = Markdown.markdownToHtml(markdown);
    return html;
  }

  private static function getTags(pathAndFileName:String) : Array<String>
  {
    var markdown = sys.io.File.getContent(pathAndFileName);
    if (tagRegex.match(markdown)) {
      var tagsString = tagRegex.matched(1); // first group

      // split on space or comma
      var splitChar = " ";
      if (tagsString.indexOf(",") > -1) {
        splitChar = ",";
      }
      var rawTags = tagsString.split(splitChar);
      var toReturn = new Array<String>();
      for (tag in rawTags) {
        toReturn.push(tag.trim());
      }
      return toReturn;
    } else {
      return new Array<String>();
    }
  }

  private static function getUrl(fileName:String) : String
  {
    return fileName.substr(0, fileName.toUpperCase().lastIndexOf('.MD'));
  }
}
