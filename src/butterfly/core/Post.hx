package butterfly.core;

using StringTools;

/**
A post extends content; it has tags, and a created-on date (unlike a Page).
*/
class Post extends Content {

  private static var publishDateRegex = ~/meta-publishedOn: (\d{4}-\d{2}-\d{2})/i;
  private static var tagRegex = ~/meta-tags: ([\w\s,\-_]+)\n/i;

  public var createdOn(default, default) : Date;
  public var tags(default, default) : Array<String>;

  public function new()
  {
    super();

    // Fields that we rely on should be initialized. Mostly for unit testing.
    this.content = "";
    this.tags = new Array<String>();
    this.createdOn = Date.now();
  }

  // fileName doesn't include any path characters
  public override function parse(pathAndFileName:String) : String
  {
    var markdown = super.parse(pathAndFileName);
    this.createdOn = getPublishDate(pathAndFileName);
    this.tags = getTags(markdown);
    return markdown;
  }
  
  /** Returns a unique list of tags across all posts */
  public static function getPostTags(posts:Array<Post>):Array<String>
  {
    var tags:Array<String> = new Array<String>();
    for (post in posts) {
      for (tag in post.tags) {
        if (tags.indexOf(tag) == -1) {
          tags.push(tag);
        }
      }
    }
    
    return tags;
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
