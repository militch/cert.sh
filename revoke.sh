#!/bin/bash

PWD=$(pwd)

cat index.txt

while true; do
if [ -z "$RM_NUM" ]; then
    read -p "Number: " RM_NUM
else
    break
fi
done

openssl ca \
-revoke "${PWD}/newcerts/${RM_NUM}.pem" \
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

default_md = sha256

policy = policy_strict

[ policy_strict ]
countryName             = match
stateOrProvinceName     = optional
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ crl_ext ]
authorityKeyIdentifier=keyid:always

EOF
)
