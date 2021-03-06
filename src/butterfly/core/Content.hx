package butterfly.core;

import haxe.crypto.Sha1;

using StringTools;

// base class for Post/Page. Not intended to be used directly.
class Content
{
  // Matches all meta-data
  private static var metaDataRegex = ~/\s*(meta-[\w\-]+:\s.*$)/igm;
  private static var idRegex = ~/\s*meta-id: (\w{40})/i;
  private static var titleRegex = ~/^\s*meta-title:(.*)$/im;
  private static var imageRegex = ~/^\s*meta-image:(.*)$/im;
  private static var imageMarkdownRegex = ~/!\[[\w\-_:\s]*\]\(([\w\-_:\/\.]+)\)/im;

  public var id(default, null) : String;
  public var title(default, default) : String;
  public var content(default, default) : String;
  public var url(default, default) : String;
  public var image(default, null):String; // used for opengraph
  public var description(default, null):String; // used for opengraph

  public function new()
  {
    this.content = "";
  }

  // fileName doesn't include any path characters
  public function parse(pathAndFileName:String) : String
  {
    var fileName = pathAndFileName.substr(pathAndFileName.lastIndexOf('/') + 1);
    var markdown = sys.io.File.getContent(pathAndFileName);
    this.url = getUrl(fileName);
    this.title = getTitle(fileName, markdown);
    this.content = getHtml(markdown);
    this.id = getAndGenerateId(pathAndFileName);
    this.image = getImage(markdown);
    this.description = getDescription(markdown);
    return markdown;
  }

  private static function getUrl(fileName:String) : String
  {
    return fileName.substr(0, fileName.toUpperCase().lastIndexOf('.MD'));
  }

  public static function getTitle(fileName:String, markdown:String) : String
  {
    // Check if there's a meta-title defined; use that (first).
    if (titleRegex.match(markdown)) {
      return titleRegex.matched(1).trim(); // first group
    } else {
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
  }

  private static function getHtml(markdown:String) : String
  {
    markdown = metaDataRegex.replace(markdown, ""); // Remove meta-data lines 
    var html = Markdown.markdownToHtml(markdown);
    return html;
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

  // Used for og:image
  private static function getImage(markdown:String):String
  {
    if (imageRegex.match(markdown)) {
      return imageRegex.matched(1).trim(); // first group
    } else if (imageMarkdownRegex.match(markdown)) {
      return imageMarkdownRegex.matched(1).trim(); // first group
    } else {
      return ""; // Image not found
    }
  }

  // Used for og:description
  private static function getDescription(markdown:String):String
  {
    var description = metaDataRegex.replace(markdown, ""); // Remove meta-data lines

    // split on \r, \n, or both
    description = description.replace("\r", "@@").replace("\n", "@@");
    var lines = description.split("@@");
    
    for (line in lines)
    {
      line = line.trim();
      if (line.length > 0 && line.indexOf("![") == -1)
      {
        // Return the first non-empty line without an image in it. And remove quotes, they break HTML.        
        var toReturn = line.replace('"', "").replace("'", "");
        return toReturn;
      }
    }
    return "";
  }
}
