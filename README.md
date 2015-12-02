![logo](logo.png)
# Butterfly

Simple, beautiful, static blogs. Butterfly combines data from JSON files with a Twitter Bootstrap UI to produce a simple, minimal blog. Perfect for hosting on websites like GitHub Pages!

- **Blazing Fast:** no server back-end required. Everything is static HTML.
- **Easy to use:** updating your blog is as easy as writing Markdown.
- **Customizable:** you control how the final HTML looks.

# Prerequisites

You need to first install:

- Haxe 3.1.3 or newer
- Neko 2.0.0 or newer

# Generating Your Site

## Inputs

Run `./run.sh` or `./run.bat` and specify where your website files are:

`./run.sh /home/myblog`

Your website files must include, at a minimum, a `src` directory with the following:

- A `layout.html` file containing your HTML template for every page, and `butterfly` markup.
  - Your layout file can contain any CSS/HTML/Javascript you like.
  - Include a `<butterfly-content />` tag, which will be replaced with actual page content (post/page content, or the list of posts for the index page).
  - Include a `<butterfly-pages />` tag, which will be replaced with a list of links to the pages.
  - Optionally include a `<butterfly-tags />` tag, which will be replaced with a list of tag links (and post count per tag).
- A `posts` directory, with one markdown file per post. 
  - The file name becomes the post name, and the markdown content becomes HTML.
  - The line`meta-tags: foo, bar, baz` tags a post with the tags `foo`, `bar`, and `baz`.
  - The line `meta-publishedOn: 2015-12-31` sets the post's publication date to December 31st, 2015.
- An optional `pages` directory which contains one markdown file per page. 
- A `content` directory containing CSS, Javascript, and `favicon` files (if they're not referenced through a CDN).
- A `config.json` file, which contains three fields: `siteName`, `authorName`, and `authorEmail`. These are used for Atom generation.

Output appears in the `bin` directory, a sibling-directory to `src`.

For an example repository, check out my [Learn Haxe blog repository](https://github.com/ashes999/learnhaxe).

## Outputs

Butterfly generates:

- One HTML page per page (`post-title.html`)
- One HTML page per post (`page-title.html`)
- One HTML page per tag, listing all posts with that tag (`tag-foo.html`)
- An Atom feed of the most recent 10 items (`atom.xml`)

## Using Google Analytics

You can paste your Google Analytics tracking code under the `<body>` opening tag as usual. If you don't want to track local views (eg. when editing/generating content), you can wrap it in a conditional `if`:

```
if (window.location.href.indexOf('file://') == -1)
{
  ... analytics code ...
}
```

This works across all browsers.
