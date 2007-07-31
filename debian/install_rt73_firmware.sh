#!/bin/sh
set -e

DRIVER="RT71W_Firmware_V1.8.zip"
URL="http://www.ralinktech.com.tw/data/$DRIVER"

bailout()
{
	[ "$1" -eq 0 ] && exit 0
	echo "ERROR $1: $2"
	exit "$1"
}

TMP="$(mktemp -dp /tmp/ rt73-fwcutter.XXXXXX)" || bailout 1 "can't create temporary directory."
[ -x /usr/bin/wget ] && DL=wget
[ -x /usr/bin/curl ] && DL="curl -o $DRIVER"

cd "$TMP"
$DL "$URL"

rt73-fwcutter "${TMP}/${DRIVER}"

mkdir -p /lib/firmware
for i in *.bin; do
        mv "$i" "/lib/firmware/$i";
done

rm -rf "$TMP"

