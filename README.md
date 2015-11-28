![logo](logo.png)
# Butterfly

Simple, beautiful, static blogs. Butterfly combines data from JSON files with a Twitter Bootstrap UI to produce a simple, minimal blog. Perfect for hosting on websites like GitHub Pages!

- Static content: no server back-end required
- Easy to write: content files are all in Markdown format
- Beautiful: uses Twitter Bootstrap for templates.

# Prerequisites

You need to first install:

- Haxe 3.1.3 or newer
- Neko 2.0.0 or newer

# Generating Your Site

Run `./run.sh` or `./run.bat` and specify where your website files are:

`./run.sh /home/myblog`

Your website files must include, at a minimum, a `src` directory with the following:

- A `layout.html` file containing your HTML template.
  - CSS, Javascript, and `favicon` files should all be sourced from a CDN, or referenced through the `content` directory.
  - Your layout file should contain exactly this HTML element, which will be replaced with an expanded `div` containing the HTML content: `<div class="blog-post" />`
- A `posts` directory, with one markdown file per post. The file name becomes the post name, and the markdown content becomes HTML.

You may also include:

- A `pages` directory, with one markdown file per page. (Pages show up in the navbar.)
- A `content` directory with CSS, Javascript, images, etc. for your site

For an example repository, check out my [Learn Haxe blog repository](https://github.com/ashes999/learnhaxe).
