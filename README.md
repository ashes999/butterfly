![logo](logo.png)
# Butterfly ![build status](https://travis-ci.org/ashes999/butterfly.svg?branch=master)

Simple, beautiful, static websites. Butterfly combines Markdown files, JSON data, and your HTML layout file to produce a static website. Perfect for hosting on websites like GitHub Pages!

- **Blazing Fast:** no server back-end required. Everything is static HTML (and Javascript, if you like).
- **Easy to use:** updating your blog is as easy as writing Markdown.
- **Customizable:** you control how the final HTML looks.


# Prerequisites

You need to install:

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
- An optional `pages` directory which contains one markdown file per page. You don't need any meta-data for it.
  - The file name becomes the post name, and the markdown content becomes HTML.
- An optional `posts` directory, with one markdown file per post.
  - The line`meta-tags: foo, bar, baz` tags a post with the tags `foo`, `bar`, and `baz`.
  - The line `meta-publishedOn: 2015-12-31` sets the post's publication date to December 31st, 2015.
  - See the "Meta-Data" section below for more information about meta-data.
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

Butterfly requires a `config.json` file. At a minimum, it should , contains the following fields: `siteName`, `siteUrl`, and `authorName` (these are used for Atom feed generation).

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

- `authorEmail`: The site owner's email. (Appears in the RSS feed.)
- `googleAnalyticsId`: Your Google Analytics site ID (eg. `UA-12345678-1`). If present, Butterfly generates the latest version of Google Analytics code. The code is wrapped in an `if` statement that prevents it from being executed if the site URL starts with `file://`.
- `homePageLayout`: The name of a file that contains the HTML template for *just the home page* (eg. `homepage.html`). Variables, butterfly tags, etc. all work as usual on this page.


# Layout.html (Template File)

Every butterfly site needs a `layout.html` file. This contains the template page that we use and populate with content (pages, posts, etc.).

## Required Tags

Your layout file needs the following tags:

- `<butterfly-content />` which renders the actual post/page content
- `<butterfly-pages />` renders the list of page titles (and links to the pages), usually for navigation. This generates a link (`a` tag) for each page. Optional attributes include:
  - `link-prefix`: An HTML/text prefix to preprend to each link (before the `<a` tag, eg. `<li>`);
  - `link-suffix`: An HTML/text suffix to attach after each link (after the `</a>` tag, eg. `</li>`)
  - `link-class`: The CSS class to specify on all links, eg. if you specify `blog-nav-item`, the HTML generated for each `a` tag includes `class="blog-nav-item"`.

## Optional Tags

You can add the following optional fields in your layout:

- `<butterfly-tags />` renders a list of `<li>tag name</li>` for each tag (ordered alphabetically). You can include the tag counts by adding `show-counts` (eg. `<butterfly-tags show-counts="true" />`). This is not recommended, because adding a new post causes every HTML file to change -- which makes it difficult to `diff` and see what really changed.
- `<butterfly-title />` renders the post title as-is.
- `<butterfly-comments />` renders the Disqus code for commenting on that page/post.
- `<butterfly-post-date />` renders the date the post was published on (doesn't render on pages). If it's not specified, butterfly generates `Posted on {date}` for posts. Optional attributes include `class` (CSS class) and `prefix` (a message to display before the date). eg. if `class` is `bear` and `prefix` is `hungry on`, Butterfly generates `<p class="bear">hungry on {date}</p>`

## Variables

Variables in your config file can be rendered in the final HTML if you put `$variable`-like placeholders in your layout template.

In your layout template, you can specify the value of any config file property, prefixed with a `$`, to substitute it for the value.  For example, with a config that includes `"siteName": "Learn Haxe"`, your layout may include:

`<h2>$siteName</h2>`

This will generate the following HTML:

`<h2>Learn Haxe</h2>`


# Post/Page Content

In general, any Markdown content will work. If you run into trouble, open an issue and let us know so we can investigate and hopefully resolve it.

## Meta-Data

Some meta-data applies only to posts; some applies only to pages; some applies to both.

### Common Meta-Data

- `meta-title`: The title of the post or page. For pages, this is the name that appears in the list generated by `<butterfly-pages />`. If unspecified, a cleaned up version of the filename becomes the title.

### Posts Only

- `meta-tags`: A comma-delimited or space-delimited set of tags for posts (not pages). (Butterfly also generates a page, per tag, listing all posts with that tag.)
- `meta-publishedOn`: The publication date of the post, in the format `YYYY-mm-dd`.

### Pages Only

- `meta-order`: The page order for pages displayed in `<butterfly-pages />`. The default page order is `0` and it's ordered ascendingly, so any negative numbers (eg. `-3`) would appear before the main list, while positive numbers will appear after the main list.

### Generated Meta-Data

The following meta-data is automatically inserted, and shouldn't be changed/deleted (unless you are *really* sure that know what you're doing):

- `meta-id`: a unique ID for each post. This is used for Disqus integration (Disqus requires a unique URL and ID for each piece of content). **Changing this could result in you losing comments on your post/page!**


# Contributing

We welcome contributions to Butterfly. Please note that you *must* write unit tests to cover any new code, and all existing tests must pass (otherwise, the build fails).
