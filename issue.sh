#!/bin/bash

csr_filepath="$1"

PWD=$(pwd)

while true; do
if [ -z "$ISSUE_DAYS" ]; then
    read -p "Days: " ISSUE_DAYS
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

openssl ca \
-md sha256 -days $ISSUE_DAYS \
-in "$csr_filepath" \
-out "certs/${OUT_NAME}.crt" \
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

crlnumber         = $PWD/crlnumber
crl               = $PWD/crl/ca.crl
crl_extensions    = crl_ext
default_crl_days  = 30

policy = policy_strict
x509_extensions = v3_ca

[ policy_strict ]
countryName             = match
stateOrProvinceName     = optional
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ crl_ext ]
authorityKeyIdentifier=keyid:always

[ v3_ca ]
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints=critical, CA:TRUE, pathlen:0
keyUsage=critical, digitalSignature, cRLSign, keyCertSign
EOF
)
