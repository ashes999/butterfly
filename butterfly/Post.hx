package butterfly;

import haxe.crypto.Sha1;
using StringTools;

class Post {
  public var title(default, null) : String;
  public var content(default, null) : String;
  public var url(default, null) : String;
  public var createdOn(default, null) : Date;
  public var tags(default, null) : Array<String>;
  public var id(default, null) : String;

  private static var publishDateRegex = ~/meta-publishedOn: (\d{4}-\d{2}-\d{2})/i;
  private static var tagRegex = ~/meta-tags: ([\w\s,\-_]+)\n/i;
  private static var idRegex = ~/meta-id: (\w{40})/i;

  public function new() {
  }

  // fileName doesn't include any path characters  
  public static function parse(pathAndFileName:String, isPage:Bool) : Post
  {
    var fileName = pathAndFileName.substr(pathAndFileName.lastIndexOf('/') + 1);
    var post = new Post();
    post.title = getTitle(fileName);
    post.url = getUrl(fileName);

    var markdown = sys.io.File.getContent(pathAndFileName);

    if (!isPage) {
      post.createdOn = getPublishDate(pathAndFileName);
    }

    post.tags = getTags(markdown);
    post.content = getHtml(markdown);
    post.id = getAndGenerateId(pathAndFileName);
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

  private static function getHtml(markdown:String) : String
  {
    // Remove meta-data lines
    markdown = tagRegex.replace(markdown, "");
    markdown = publishDateRegex.replace(markdown, "");
    markdown = idRegex.replace(markdown, "");

    var html = Markdown.markdownToHtml(markdown);
    return html;
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

  private static function getUrl(fileName:String) : String
  {
    return fileName.substr(0, fileName.toUpperCase().lastIndexOf('.MD'));
  }

  // Gets the ID from the file. If there's no ID, inserts and returns the ID.
  private static function getAndGenerateId(fileName:String) : String
  {
    var markdown = sys.io.File.getContent(fileName);
    if (!idRegex.match(markdown)) {
      // Hash the markdown as the id. Any ID will do, really.
      trace('Generated new ID for ${fileName}');
      var id = Sha1.encode(markdown);
      markdown = 'meta-id: ${id}

${markdown}';
      sys.io.File.saveContent(fileName, markdown);
      return id;
    } else {
      return idRegex.matched(1);
    }
  }
}
