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

## Qick-Start

Run `./run.sh` or `./run.bat` and specify where your website files are:

`./run.sh /home/myblog`

Your website files must include, at a minimum, a `src` directory with the following:

- A `layout.html` file containing your HTML template for every page, and `butterfly` markup.
  - Your layout file can contain any CSS/HTML/Javascript you like.
  - Include a `<butterfly-content />` tag, which will be replaced with actual page content (post/page content, or the list of posts for the index page).
  - Include a `<butterfly-pages />` tag, which will be replaced with a list of links to the pages.
  - Optionally include a `<butterfly-tags />` tag, which will be replaced with a list of tag links.
- An optional `posts` directory, with one markdown file per post.
  - The file name becomes the post name, and the markdown content becomes HTML.
  - The line`meta-tags: foo, bar, baz` tags a post with the tags `foo`, `bar`, and `baz`.
  - The line `meta-publishedOn: 2015-12-31` sets the post's publication date to December 31st, 2015.
- An optional `pages` directory which contains one markdown file per page. You son't need any meta-entries for it.
- A `content` directory containing CSS, Javascript, and `favicon` files (if they're not referenced through a CDN).
- A `config.json` file. See the *JSON Configuration* section for information on what goes in here. It must have at least `siteName`, `siteUrl`, and `authorName` defined.

Output appears in the `bin` directory, a sibling-directory to `src`.

For an example repository, check out my [Learn Haxe blog repository](https://github.com/ashes999/learnhaxe).

## What's Generated

Butterfly generates:

- One HTML page per page (`post-title.html`)
- One HTML page per post (`page-title.html`)
- One HTML page per tag, listing all posts with that tag (`tag-foo.html`)
- An Atom feed of the most recent 10 items (`atom.xml`)

# JSON Configuration

Butterfly requires a `config.json` file. At a minimum, it should , contains the following fields: `siteName`, `siteUrl`, `authorName`, and `authorEmail` (these are used for Atom feed generation).

## Required Attributes

A minimal `config.json` file looks like this:

```
{
  "siteName": "Learn Haxe",
  "siteUrl": "http://ashes999.github.io/learnhaxe",
  "authorName": "ashes999",
}
```

## Optional Attributes

- `authorEmail`: the site owner's email. (Appears in the RSS feed.)
- `googleAnalyticsId`: Your Google Analytics site ID (eg. `UA-12345678-1`). If present, Butterfly generates the latest version of Google Analytics code. The code is wrapped in an `if` statement that prevents it from being executed if the site URL starts with `file://`.

# Layout.html (Template File)

Every butterfly site needs a `layout.html` file. This contains the template page that we use and populate with content (pages, posts, etc.).

## Required Tags

Your layout file needs the following tags:

- `<butterfly-content />` which renders the actual post/page content
- `<butterfly-pages />` renders the list of page titles (and links to the pages), usually for navigation. This generates a link (`a` tag) for each page. Optional attributes include:
  - `link-prefix`: An HTML/text prefix to preprend to each link (before the `<a` tag, eg. `<li>`);
  - `link-suffix`: an HTML/text suffix to attach after each link (after the `</a>` tag, eg. `</li>`)
  - `link-attributes`: HTML to inject within the anchor tag, eg. `class="blog-nav-item"`

## Optional Tags

You can add the following optional fields in your layout:

- `<butterfly-tags />` renders a list of `<li>tag name</li>` for each tag (ordered alphabetically). You can include the tag counts by adding `show-counts` (eg. `<butterfly-tags show-counts="true" />`). This is not recommended, because adding a new post causes every HTML file to change -- which makes it difficult to `diff` and see what really changed.
- `<butterfly-title />` renders the post title as-is.
- `<butterfly-comments />` renders the Disqus code for commenting on that page/post.

## Variables

Variables in your config file can be rendered in the final HTML if you put `$variable`-like placeholders in your layout template.

In your layout template, you can specify the value of any config file property, prefixed with a `$`, to substitute it for the value.  For example, with a config that includes `"siteName": "Learn Haxe"`, your layout may include:

`<h2>$siteName</h2>`

This will generate the following HTML:

`<h2>Learn Haxe</h2>`
