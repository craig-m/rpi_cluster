#!/bin/bash

# test /usr/bin/sudo <cmd> works OK
/usr/bin/sudo id | grep "uid=0(root)" > /dev/null 2>&1 || exit 1;

# Generate an RSA key for the CA:
openssl genrsa -out b3rry.clust0r.key 2048

# show debug info:
#openssl rsa -in b3rry.clust0r.key -noout -text

# extract the public rsa key from the private rsa key
openssl rsa -in b3rry.clust0r.key -pubout -out b3rry.clust0r.pubkey

# show debug info:
#openssl rsa -in b3rry.clust0r.pubkey -pubin -noout -text

# generate a CSR
openssl req -new -key bc.key -out bc.csr -subj "/C=AU/ST=Sydney/L=Sydney/O=rpi_cluster/OU=rpi_cluster/CN=status.b3rry.clust0r"

# show debug info:
#openssl req -new -out bc.csr -config bc.conf
#openssl req -in bc.csr -noout -text

# Create CA keys
openssl genrsa -out ca.key 2048
openssl req -new -x509 -key ca.key -out ca.crt -subj "/C=AU/ST=Sydney/L=Sydney/O=rpi_cluster CA/OU=rpi_cluster IT"

# sign CSR
openssl x509 -req -in bc.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out bc.crt

# show debug info:
#openssl x509 -in bc.crt -noout -text

cat bc.crt ca.crt > bc.bundle.crt
cat bc.key >> bc.bundle.crt

/usr/bin/sudo cp ca.crt /usr/local/share/ca-certificates/
/usr/bin/sudo update-ca-certificates

# EOF
