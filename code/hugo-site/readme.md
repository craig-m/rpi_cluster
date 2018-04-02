Local R-Pi Cluster website, made with Hugo

Requires:
* Hugo - https://gohugo.io/
* Yarn - https://yarnpkg.com/en/
* Node/NPM - https://www.npmjs.com/

Site made with: bootstrap + jquery + font-awesome

start dev server:

```
hugo server --watch
```

build + upload:

```
hugo -v
rsync -avr public/ pi@omega.local:/srv/nginx/hugo-site/;
```

http://status.b3rry.clust0r
