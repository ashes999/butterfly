package butterfly.core;

using StringTools;

/**
A post extends content; it has tags, and a created-on date (unlike a Page).
*/
class Post extends Content {

  private static var publishDateRegex = ~/meta-publishedOn: (\d{4}-\d{2}-\d{2})/i;
  private static var tagRegex = ~/meta-tags: ([\w\s,\-_]+)\n/i;

  public var createdOn(default, null) : Date;
  public var tags(default, default) : Array<String>;

  public function new()
  {
    super();

    // Fields that we rely on should be initialized. Mostly for unit testing.
    this.tags = new Array<String>();
    this.createdOn = Date.now();
  }

  // fileName doesn't include any path characters
  public static function parse(pathAndFileName:String) : Post
  {
    var post:Post = cast(Content.parse(pathAndFileName));
    var markdown = sys.io.File.getContent(pathAndFileName);

    post.createdOn = getPublishDate(pathAndFileName);
    post.tags = getTags(markdown);
    return post;
  }

  private static function getTags(markdown:String) : Array<String>
  {
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

  private static function getPublishDate(fileName:String) : Date
  {
    var markdown = sys.io.File.getContent(fileName);
    var regex = publishDateRegex;
    if (regex.match(markdown)) {
      var dateString = regex.matched(1); // first group
      return Date.fromString(dateString);
    } else {
      throw '${fileName} does not seem to have a valid published-on meta date. Please make sure the content contains a line containing: meta-publishedOn: YYYY-mm-dd';
    }
  }
}
