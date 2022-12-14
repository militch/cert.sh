#!/bin/bash
set -e

PATH_NAME=$1

while true; do
if [ -z "$PATH_NAME" ]; then
    read -p "Path Name: " PATH_NAME
else
    break
fi
done

while true; do
if [ -z "$COMMON_NAME" ]; then
    read -p "Common Name: " COMMON_NAME
else
    break
fi
done

while true; do
if [ -z "$ISSUE_DAYS" ]; then
    read -p "Issue Days: " ISSUE_DAYS
else
    break
fi
done

mkdir -p $PATH_NAME/certs \
    $PATH_NAME/crl \
    $PATH_NAME/newcerts \
    $PATH_NAME/csr \
    $PATH_NAME/private

cp issue-client.sh $PATH_NAME/
cp issue-server.sh $PATH_NAME/
cp issue-webserver.sh $PATH_NAME/

touch $PATH_NAME/index.txt \
&& echo 1000 > $PATH_NAME/serial



KEYFILE="$PATH_NAME/private/${PATH_NAME}.key"
CSRFILE="$PATH_NAME/csr/${PATH_NAME}.csr"

openssl req -new -sha256 \
-subj "/C=CN/L=Shenzhen/O=Dashuyun/CN=${COMMON_NAME}" \
-newkey rsa -nodes \
-keyout "$KEYFILE" -out "$CSRFILE" \
-config <( \
cat << EOF
[req]
default_bits=4096
string_mask=utf8only
distinguished_name=dn
[dn]
EOF
)

CERTFILE="$PATH_NAME/certs/${PATH_NAME}.crt"

PWD=$(pwd)

openssl ca \
-md sha256 -days $ISSUE_DAYS \
-in "$CSRFILE" \
-out "$CERTFILE" \
-notext \
-config <( \
cat << EOF
[ ca ]
default_ca = CA_default
[ CA_default ]
certs = $PWD/certs
crl_dir = $PWD/crl
new_certs_dir = $PWD/newcerts
database = $PWD/index.txt
serial = $PWD/serial
RANDFILE = $PWD/private/.rand

private_key = $PWD/private/root.key
certificate = $PWD/certs/root.crt

policy = policy_strict
x509_extensions = v3_ca

[ policy_strict ]
countryName             = match
stateOrProvinceName     = optional
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ v3_ca ]
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints=critical, CA:TRUE, pathlen:0
keyUsage=critical, digitalSignature, cRLSign, keyCertSign
EOF
)
