#!/bin/bash
KEYNAME=$1
VMS="${@:2}"

if [ -z "$1" ]; then
  if [ -z "$2"]; then
    echo "usage: genspiped <keyname> [vms...]"
    exit 1
  fi
fi

dd bs=1 count=32 if=/dev/urandom of=temp.key > /dev/null 2>&1
for x in $VMS; do
  nixops scp --to $x temp.key /var/lib/spiped/$KEYNAME.key
  nixops ssh $x -- systemctl restart spiped@$KEYNAME > /dev/null 2>&1
done
rm -f temp.key
