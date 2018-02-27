+++
categories = ["webdev","rpi-cluster"]
date = "2017-05-26T17:34:14+10:00"
tags = ["hugo","webdev"]
title = "hugo theme"

+++

## Creating a new theme

In the hugo directory:

```
$ hugo new theme berrycluster
```
references <a href="https://gohugo.io/themes/creation/">https://gohugo.io/themes/creation/</a>

The new theme files:

```
$ tree -a -L 4 themes/berrycluster/
|
├── LICENSE.md
├── archetypes
│   └── default.md
├── layouts
│   ├── 404.html
│   ├── _default
│   │   ├── list.html
│   │   └── single.html
│   ├── index.html
│   └── partials
│       ├── footer.html
│       └── header.html
├── static
│   ├── css
│   └── js
└── theme.toml

7 directories, 9 files

```

Start hugo with the new theme:
```
$ hugo server --theme=berrycluster
```

Everything at http://localhost:1313/ is blank, this is OK. The default theme is empty.


# edit the theme

#### themes/berrycluster/layouts/index.html</b>
```
{{ partial "header" . }}
<ul>
{{ range .Data.Pages }}
<li>
  <a href="{{ .Permalink }}">{{ .Title }}</a> {{ .Date.Format "Mon, Jan 2, 2006" }}
</li>
{{ end }}
</ul>
{{ partial "footer" . }}
```

#### themes/berrycluster/layouts/_default/list.html
```
{{ partial "header" . }}
<ul>
{{ range .Data.Pages }}
<li>
  <a href="{{ .Permalink }}">{{ .Title }}</a> {{ .Date.Format "Mon, Jan 2, 2006" }}
</li>
{{ end }}
</ul>
{{ partial "footer" . }}
```

#### themes/berrycluster/layouts/_default/single.html
```
{{ partial "header" . }}
<div class="content container">
    <h1>{{ .Title }}</h1>
    <span class="post-date">{{ .Date.Format "Mon, Jan 2, 2006" }}</span>
        {{ .Content }}
  </div>
{{ partial "footer" . }}
```

#### themes/berrycluster/layouts/partials/header.html
```
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<title>{{ .Title }}</title>
	<meta name="description" content="R-Pi Cluster site">
  {{ .Hugo.Generator }}
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous">
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
</head>
<body>

<header>{{ .Site.Title }} </header>

<ul class="sidebar-menu">
  {{ $currentPage := . }}
  {{ range .Site.Menus.main }}
    <li>
    <a href="{{.URL}}">
        {{ .Pre }}
        <span>{{ .Name }}</span>
    </a>
  {{end}}
</ul>
```

#### themes/berrycluster/layouts/partials/footer.html
```
<footer>
Inspirational quote
</footer>
</body>
</html>
```

Add menu itemes in site config:
```
[[menu.main]]
    name = "test"
    pre = "<i class='fa fa-road'></i>"
    weight = -100
    url = "/test/"
[[menu.main]]
    name = "post"
    pre = "<i class='fa fa-road'></i>"
    weight = -100
    url = "/post/"
```

