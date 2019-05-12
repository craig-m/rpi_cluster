
This status website is hosted on the Omega R-Pi node.

Requires:
* Hugo - https://gohugo.io/
* Yarn - https://yarnpkg.com/en/
* Node/NPM - https://www.npmjs.com/

Site made with: bootstrap + jquery + font-awesome.


```
./install_hugo.sh
```


build + upload:

```
export PATH=$PATH:/home/pi/go/bin/
hugo
rsync -avr public/ pi@omega.local:/srv/nginx/hugo-site/;
```

http://status.b3rry.clust0r
