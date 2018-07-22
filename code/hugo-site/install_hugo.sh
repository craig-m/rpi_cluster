#!/bin/bash
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:/home/pi/go/bin/
# https://gohugo.io/getting-started/installing/
go get github.com/magefile/mage
go get -d github.com/gohugoio/hugo
cd ${GOPATH:-$HOME/go}/src/github.com/gohugoio/hugo
mage vendor
mage install
