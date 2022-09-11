#!/bin/bash
set -e

filename="$1"

while true; do
if [ -z "$filename" ]; then
    read -p "Filename: " filename
else
    break
fi
done

while true; do
if [ -z "$ISSUE_DOMAIN" ]; then
    read -p "Domain: " ISSUE_DOMAIN
else
    break
fi
done

COMMON_NAME="${ISSUE_DOMAIN}"

while true; do
if [ -z "$ISSUE_DAYS" ]; then
    read -p "Issue Days: " ISSUE_DAYS
else
    break
fi
done


KEYFILE="private/${filename}.key"
CSRFILE="csr/${filename}.csr"

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


CERTFILE="certs/${filename}.crt"

PWD=$(pwd)
agent=$(basename $PWD)

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

private_key = $PWD/private/${agent}.key
certificate = $PWD/certs/${agent}.crt

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
authorityKeyIdentifier=keyid, issuer:aways
basicConstraints=critical, CA:FALSE
keyUsage=critical, digitalSignature, keyEncipherment
subjectAltName=@alt_names
[ alt_names ]
DNS=${ISSUE_DOMAIN}
EOF
)
