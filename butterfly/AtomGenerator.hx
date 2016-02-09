package butterfly;

using DateTools;
using haxe.crypto.Md5;

class AtomGenerator {
  public static function generate(posts:Array<butterfly.Post>, config:Dynamic):String
  {
    var siteName:String = config.siteName;
    var authorName:String = config.authorName;
    var authorEmail:String = config.authorEmail;
    var lastUpdated:Date = Date.now();

    // Posts are sorted reverse chronologically. Anyway, get the newest date
    // of the newest post as our last-updated date. (If there are no posts,
    // and since pages don't have a publication date, we use today's date.)
    if (posts.length > 0) {
      lastUpdated = posts[0].createdOn;
      for (post in posts) {
        if (post.createdOn.getTime() >= lastUpdated.getTime()) {
          lastUpdated = post.createdOn;
        }
      }
    }

    var xml = '<?xml version="1.0" encoding="utf-8"?>
      <feed xmlns="http://www.w3.org/2005/Atom">
        <title>${siteName}</title>
        <link href="${config.siteUrl}" />
        <id>urn:uuid:${Md5.encode(siteName)}</id>
  	    <updated>${toIsoTime(lastUpdated)}</updated>';

    for (i in 0...Math.round(Math.min(posts.length, 10))) {
      var post = posts[i];
      var url = '${config.siteUrl}/${post.url}';
      xml += '<entry>
      		<title>${post.title}</title>
          <link href="${url}" />
      		<id>urn:uuid:${Md5.encode(post.title)}</id>
      		<updated>${toIsoTime(post.createdOn)}</updated>
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
