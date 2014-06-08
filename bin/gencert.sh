#!/bin/bash

# Bash shell script for generating self-signed certs, and uploading them to
# a machine (mostly for testing). Based on:
#  - https://gist.github.com/bradland/1690807
VM="$1"
DOMAIN="$1.haskell.org"
if [ -z "$VM" ]; then
  echo "Usage: $(basename $0) <nixops virtual machine>"
  exit 11
fi

fail_if_error() {
  [ $1 != 0 ] && {
    unset PASSPHRASE
    exit 10
  }
}

# Generate a passphrase
export PASSPHRASE=$(head -c 500 /dev/urandom \
                   | tr -dc a-z0-9A-Z \
                   | head -c 128; echo)

# Certificate details; replace items in angle brackets with your own info
subj="
C=US
ST=Texas
O=Haskell.org
localityName=Austin
commonName=$DOMAIN
organizationalUnitName=Administration
emailAddress=admin@haskell.org
"

# Generate the server private key
openssl genrsa -des3 -out temp.key -passout env:PASSPHRASE 2048
fail_if_error $?

# Generate the CSR
openssl req \
    -new \
    -batch \
    -subj "$(echo -n "$subj" | tr "\n" "/")" \
    -key temp.key \
    -out temp.csr \
    -passin env:PASSPHRASE
fail_if_error $?
cp temp.key temp.key.org
fail_if_error $?

# Strip the password so we don't have to type it every time we restart Apache
openssl rsa -in temp.key.org -out temp.key -passin env:PASSPHRASE
fail_if_error $?

# Generate the cert (good for 10 years)
openssl x509 -req -days 3650 -in temp.csr -signkey temp.key -out temp.crt
fail_if_error $?

# Create the root dir on the host
nixops ssh $VM -- mkdir -p /root/ssl
# Upload files
for x in csr key crt; do
  nixops scp --to $VM temp.$x /root/ssl/haskell.org.$x
done
# Delete files
rm -f temp.csr temp.key temp.crt temp.key.org
