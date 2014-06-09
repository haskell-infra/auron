with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "gencert";

  phases = "installPhase";
  installPhase = ''
    mkdir -p $out/bin
    touch $out/bin/gencert && chmod +x $out/bin/gencert
    cat > $out/bin/gencert <<EOF
    #!${bash}/bin/bash

    # Bash shell script for generating self-signed certs, and uploading them to
    # a machine (mostly for testing). Based on:
    #  - https://gist.github.com/bradland/1690807
    mkdir -p /root/ssl
    DOMAIN="\`hostname\`.haskell.org"

    fail_if_error() {
      [ \$1 != 0 ] && {
        unset PASSPHRASE
        exit 10
      }
    }

    # Generate a passphrase
    export PASSPHRASE=\$(head -c 500 /dev/urandom \
                       | tr -dc a-z0-9A-Z \
                       | head -c 128; echo)

    # Certificate details; replace items in angle brackets with your own info
    subj="
    C=US
    ST=Texas
    O=Haskell.org
    localityName=Austin
    commonName=\$DOMAIN
    organizationalUnitName=Administration
    emailAddress=admin@haskell.org
    "

    # Generate the server private key
    ${openssl}/bin/openssl genrsa -des3 -out /root/ssl/haskell.org.key \
      -passout env:PASSPHRASE 2048
    fail_if_error \$?

    # Generate the CSR
    ${openssl}/bin/openssl req \
        -new \
        -batch \
        -subj "\$(echo -n "\$subj" | tr "\n" "/")" \
        -key /root/ssl/haskell.org.key \
        -out /root/ssl/haskell.org.csr \
        -passin env:PASSPHRASE
    fail_if_error \$?
    cp /root/ssl/haskell.org.key /root/ssl/haskell.org.key.org
    fail_if_error \$?

    # Strip the password
    ${openssl}/bin/openssl rsa -in /root/ssl/haskell.org.key.org \
      -out /root/ssl/haskell.org.key -passin env:PASSPHRASE
    fail_if_error \$?
    rm -f /root/ssl/haskell.org.key.org

    # Generate the cert (good for 10 years)
    ${openssl}/bin/openssl x509 -req -days 3650 -in /root/ssl/haskell.org.csr \
      -signkey /root/ssl/haskell.org.key -out /root/ssl/haskell.org.crt
    fail_if_error \$?
    exit 0
    EOF
  '';
}
