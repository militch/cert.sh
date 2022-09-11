#!/bin/bash

while true; do
if [ -z "$CN" ]; then
    read -p "Commen Name: " CN
else
    break
fi
done

while true; do
if [ -z "$OUT_NAME" ]; then
    read -p "Outname: " OUT_NAME
else
    break
fi
done

KEYFILE="private/${OUT_NAME}.key"
CSRFILE="csr/${OUT_NAME}.csr"

openssl req -new -sha256 \
-subj "/C=CN/L=Shenzhen/O=Dashuyun/CN=${CN}" \
-newkey rsa -nodes \
-keyout "$KEYFILE" -out "$CSRFILE" \
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
authorityKeyIdentifier=keyid:always,issuer
basicConstraints=critical, CA:TRUE, pathlen:0
keyUsage=critical, digitalSignature, cRLSign, keyCertSign
EOF
)

