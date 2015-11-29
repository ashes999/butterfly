package butterfly;

using DateTools;
using haxe.crypto.Md5;

class AtomGenerator {
  public static function generate(posts:Array<butterfly.Post>, config:Dynamic):String
  {
    var siteName = config.siteName;
    var authorName = config.authorName;
    var authorEmail = config.authorEmail;

    var lastUpdated = posts[0].createdOn;
    var xml = '<?xml version="1.0" encoding="utf-8"?>
      <feed xmlns="http://www.w3.org/2005/Atom">
        <title>${siteName}</title>
        <id>urn:uuid:${Md5.encode(siteName)}</id>
  	    <updated>${toIsoTime(lastUpdated)}</updated>';

    for (i in 0...Math.round(Math.min(posts.length, 10))) {
      var post = posts[i];
      xml += '<entry>
      		<title>${post.title}</title>
      		<id>urn:uuid:${Md5.encode(post.title)}</id>
      		<updated>${toIsoTime(post.updatedOn)}</updated>
      		<summary>${post.title}</summary>
      		<content type="xhtml">
      			${post.content}
      		</content>
      		<author>
      			<name>${authorName}</name>
      			<email>${authorEmail}</email>
      		</author>
      	</entry>';
    }
    xml += "</feed>";
    return xml;
  }

  private static function toIsoTime(date:Date):String
  {
    // We're not accomodating for timzeones.
    return date.format("%Y-%m-%d") + "T" + date.format("%T") + "Z";
  }
}
