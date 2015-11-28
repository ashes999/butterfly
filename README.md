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

Run `./run.sh` or `./run.bat` and specify where your website files are:

`./run.sh /home/myblog`

Your website files must include, at a minimum, a `src` directory with the following:

- A `layout.html` file containing your HTML template, and `butterfly` markup.
  - Your layout file can contain any CSS/HTML/Javascript you like.
  - Include a `<butterfly-content />` tag, which will be replaced with actual page content (post/page content, or the list of posts for the index page).
  - Include a `<butterfly-pages />` tag, which will be replaced with a list of links to the pages.
- A `posts` directory, with one markdown file per post. The file name becomes the post name, and the markdown content becomes HTML.
- CSS, Javascript, and `favicon` files should all be sourced from a CDN, or referenced through the `content` directory.

You may also include:

- A `pages` directory, with one markdown file per page. (Pages show up in the navbar.)
- A `content` directory with CSS, Javascript, images, etc. for your site

For an example repository, check out my [Learn Haxe blog repository](https://github.com/ashes999/learnhaxe).
