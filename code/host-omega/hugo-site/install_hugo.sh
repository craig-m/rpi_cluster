#!/bin/bash
echo "Installing Hugo";

export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:/home/pi/go/bin/
/usr/local/go/bin/go version || exit 1;

# https://gohugo.io/getting-started/installing/
go get github.com/magefile/mage
go get -d github.com/gohugoio/hugo
cd ${GOPATH:-$HOME/go}/src/github.com/gohugoio/hugo

mage vendor
mage install

~/go/bin/hugo version
