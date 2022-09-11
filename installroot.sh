#!/bin/bash
set -e

mkdir certs crl newcerts private

touch index.txt \
&& echo 1000 > serial

openssl req -new -x509 -sha256 \
-subj '/C=CN/L=Shenzhen/O=Dashuyun/CN=Dashuyun Root' \
-days 3650 \
-newkey rsa -nodes \
-keyout private/root.key -out certs/root.crt \
-config <( \
cat << EOF
[req]
default_bits=4096
string_mask=utf8only
distinguished_name=dn
x509_extensions=v3_ca
[dn]
[v3_ca]
subjectKeyIdentifier=hash
basicConstraints=critical, CA:TRUE
keyUsage=critical, cRLSign, keyCertSign
EOF
)
