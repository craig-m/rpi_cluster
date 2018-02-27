+++
categories = ["webdev","rpi-cluster"]
date = "2017-05-26T17:13:35+10:00"
tags = ["hugo","webdev"]
title = "first post"

+++

Setting up Hugo to create this first post.

# setup

Install the <a href="https://github.com/spf13/hugo/releases">hugo binary</a> with brew/apt etc.

Create the new hugo site:
```
$ mkdir hugo-site
$ cd hugo-site/
$ hugo new site .
Congratulations! Your new Hugo site is created in /ZZZ/code/hugo-site.
```

# first post

## archetype

create the file archetypes/default.md
```
+++
tags = ["x", "y"]
categories = ["x", "y"]
+++
```
Link to ref: <a href="https://gohugo.io/content/archetypes/">https://gohugo.io/content/archetypes/</a>

## create it

First post:
```
$ hugo new post/first-post.md
$ vim post/first-post.md
```
edit the post and add some content.

## hugo theme/config

Install a theme:
```
$ cd themes
$ git clone https://github.com/spf13/hyde.git
$ cd ..
```

Hugo config (config.toml in root):
```
languageCode = "en-us"
title = "R-Pi cluster"
baseURL = "/"
buildDrafts = false
theme = "hyde"

[taxonomies]
  category = "categories"
  tag = "tags"

[params]
  description = "Local portal for my Pi cluster."
  author = "crgm"
```

# done

The filesystem layout:

```
$ tree -f -L 2
.
├── ./archetypes
│   └── ./archetypes/default.md
├── ./config.toml
├── ./content
│   └── ./content/post
├── ./data
├── ./layouts
├── ./public
│   ├── ./public/404.html
│   ├── ./public/apple-touch-icon-144-precomposed.png
│   ├── ./public/categories
│   ├── ./public/css
│   ├── ./public/favicon.png
│   ├── ./public/index.html
│   ├── ./public/index.xml
│   ├── ./public/post
│   ├── ./public/sitemap.xml
│   └── ./public/tags
├── ./static
└── ./themes
    └── ./themes/hyde

13 directories, 8 files
```

Start hugo:
```
$ hugo server --watch
```

The site is now available at http://localhost:1313/
