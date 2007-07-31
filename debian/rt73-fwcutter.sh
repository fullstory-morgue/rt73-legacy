#!/bin/sh
set -e

bailout()
{
	[ "$1" -eq 0 ] && exit 0
	echo "ERROR $1: $2"
	exit "$1"
}

FW_DIR="$(pwd)"
TMP="$(mktemp -dp /tmp/ rt73-fwcutter.XXXXXX)" || bailout 1 "can't create temporary directory."

[ -z "$1" ] && bailout 2 "no input filename."
[ -r "$1" ] || bailout 3 "input tarball does not exist."

cd "$TMP"
unp "$1" || bailout 4 "input archive $1 could not be extracted."
find "$TMP" -iname rt73.bin  >/dev/null || bailout 5 "rt73.bin can\'t be found."
find "$TMP" -iname \*\\.bin -exec cp {} "${FW_DIR}/" \;

