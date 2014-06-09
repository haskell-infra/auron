#!/bin/bash
KEYNAME=$1
VMS="${@:2}"

if [ -z "$1" ]; then
  if [ -z "$2"]; then
    echo "usage: genspiped <keyname> [vms...]"
    exit 1
  fi
fi

dd bs=1 count=32 if=/dev/urandom of=temp.key
for x in $VMS; do
  nixops scp --to $x temp.key /var/lib/spiped/$KEYNAME.key
done
rm -f temp.key
