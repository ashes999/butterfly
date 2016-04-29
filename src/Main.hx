using StringTools;
using DateTools;

import butterfly.core.ButterflyConfig;
import butterfly.core.Content;
import butterfly.core.Post;
import butterfly.core.Page;
import butterfly.generator.AtomGenerator;
import butterfly.generator.HtmlGenerator;
import butterfly.html.FileWriter;
import butterfly.html.LayoutModifier;
import butterfly.io.ArgsParser;
using noor.StringExtensions;
using noor.io.FileSystemExtensions;
import sys.FileSystem;

class Main {
	static public function main() : Void
    {
		new Main().run(Sys.args());
	}

	public function new() { }

	public function run(args:Array<String>) : Void
    {
		// Initial setup/validation
		var projectDir:String = ArgsParser.extractProjectDirFromArgs(args); 
		var binDir:String = '${projectDir}/bin';
		FileSystem.recreateDirectory(binDir); 
		var srcDir = '${projectDir}/src';
		FileSystem.ensureDirectoryExists(srcDir);
		var config:ButterflyConfig = ButterflyConfig.fromFile('${srcDir}/config.json');

		// Start creating content files
		var pages:Array<Page> = getPages(srcDir);
		var posts:Array<Post> = getPosts(srcDir);
		var tags:Array<String> = Post.getPostTags(posts);
		FileSystem.copyDirectoryRecursively('${srcDir}/content', '${binDir}/content');

		// Start HTML generation
		var layoutHtml = getAndValidateLayoutHtml(srcDir, config, posts, pages);
		generateHtmlPages(posts, pages, tags, layoutHtml, srcDir, binDir, config);
		generateRssFeed(posts, binDir, config);

		trace('Generated index page, ${pages.length} page(s), and ${posts.length} post(s).');
	}

	/**
	Generates the index.html (home page) file. By default, this uses the same
	layout as everything else, and fills in <butterfly-content /> with a list of
	posts, ordered chronologically descending.
	If homePageLayout is specified in the config file, that HTML file is used
	instead for the home page's layout.
	*/
	private function generateIndexPage(config:ButterflyConfig, srcDir:String, posts:Array<Post>,
		pages:Array<Page>, generator:HtmlGenerator, writer:FileWriter) : Void
	{
		var indexPageHtml:String;
		if (config.homePageLayout != null) {
			var homePageLayoutFile:String = '${srcDir}/${config.homePageLayout}';
			var homePageHtml = new LayoutModifier(homePageLayoutFile, config, posts, pages, false).getHtml();
			var homePageGenerator:HtmlGenerator = new HtmlGenerator(homePageHtml, posts, pages);
			indexPageHtml = homePageGenerator.generateHomePageHtml();
		} else {
			indexPageHtml = generator.generateHomePageHtml();
		}
		writer.write("index.html", indexPageHtml);
	}

	// Performs a sort on posts itself. Orders reverse-chronologically.
	private function sortPosts(posts:Array<Post>) : Void
	{
		if (posts.length > 0) {
			// Sorting by getTime() doesn't seem to work, for some reason; sorting by
			// the stringified dates (yyyy-mm-dd format) does.
			haxe.ds.ArraySort.sort(posts, function(a, b) {
				var x = a.createdOn.format("%Y-%m-%d");
				var y = b.createdOn.format("%Y-%m-%d");

				if (x < y ) { return 1; }
				else if (x > y) { return -1; }
				else { return 0; };
			});
		}
	}

	// Performs a sort on pages itself. Orders by "order" field.
	private function sortPages(pages:Array<Page>) : Void
	{
		if (pages.length > 0) {
			haxe.ds.ArraySort.sort(pages, function(a, b) {
				var x = a.order;
				var y = b.order;

				if (x < y ) { return -1; }
				else if (x > y) { return 1; }
				else {
						// if tied, sort by title ascending
						var m = a.title;
						var n = b.title;
						if (m < n) { return -1; }
						else if (m > n) { return 1; }
						else { return 0; };
				}
			});
		}
	}
		
	private function getPages(srcDir:String):Array<Page> {
		var pages:Array<Page> = new Array<Page>();

		var files:Array<String> = FileSystem.getFiles('${srcDir}/pages');
		for (file in files) {
			var p = new Page();
			p.parse(file);
			pages.push(p);
		}

		sortPages(pages);
		return pages;
	}
	
	private function getPosts(srcDir:String):Array<Post> {
		var posts:Array<Post> = new Array<Post>();

		var files:Array<String> = FileSystem.getFiles('${srcDir}/posts');
		for (file in files) {
			var p = new Post();
			p.parse(file);
			posts.push(p);
		}

		sortPosts(posts);
		return posts;
	}
	
	private function getAndValidateLayoutHtml(srcDir:String, config:ButterflyConfig,
		posts:Array<Post>, pages:Array<Page>):String
    {
		var layoutFile = '${srcDir}/layout.html';
		var layoutHtml = new LayoutModifier(layoutFile, config, posts, pages).getHtml();
		if (layoutHtml.indexOf(HtmlGenerator.CONTENT_PLACEHOLDER) == -1)
        {
			throw "Layout HTML doesn't have the blog post placeholder in it: " + HtmlGenerator.CONTENT_PLACEHOLDER;
		}
		return layoutHtml;
	}
	
	private function generateHtmlPages(posts:Array<Post>, pages:Array<Page>, tags:Array<String>,
		layoutHtml:String, srcDir:String, binDir:String, config:ButterflyConfig):Void {
		var generator = new HtmlGenerator(layoutHtml, posts, pages);
		var writer = new FileWriter(binDir);

		this.generateHtmlFilesForPosts(posts, generator, config, writer);
		this.generateHtmlFilesForPages(pages, generator, config, writer);

		for (tag in tags)
		{
			var html = generator.generateTagPageHtml(tag, posts);
			writer.write('tag-${tag}.html', html);
		}

		this.generateIndexPage(config, srcDir, posts, pages, generator, writer);
	}

	private function generateHtmlFilesForPosts(posts:Array<Post>, generator:HtmlGenerator,
		config:ButterflyConfig, writer:FileWriter) : Void
	{
		for (post in posts) {
			var html = generator.generatePostHtml(post, config);
			writer.writeContent(post, html);
		}
	}

	private function generateHtmlFilesForPages(pages:Array<Page>, generator:HtmlGenerator,
		config:ButterflyConfig, writer:FileWriter) : Void
	{
		for (page in pages) {
			var html = generator.generatePageHtml(page, config);
			writer.writeContent(page, html);
		}
	}


	private function generateRssFeed(posts:Array<Post>, binDir:String, config:ButterflyConfig):Void {
		var writer = new FileWriter(binDir);			
		var atomXml = AtomGenerator.generate(posts, config);
		writer.write("atom.xml", atomXml);
	}
}

