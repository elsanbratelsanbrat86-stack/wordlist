#!/bin/sh

set -e


usage() {
    echo "usage: $0 <verstr>"
    exit 1
}

if [ $# -ne 1 ]; then
    usage
fi

VERSTR="$1"
DEST=scowl-"$VERSTR"

rm -f scowl.db
./combine.py create-db scowl.db
./scowl export --db scowl.db > scowl.txt

git ls-files -z -- ':(glob,exclude)**/.gitignore' Copyright libscowl misc/comp-60.txt mk-list postgresql README.md scowl speller > files-to-copy 

rm -rf "$DEST"
rsync -a . -0 --files-from=files-to-copy "$DEST"/
echo -n "#: Release $VERSTR from git revision " >> "$DEST"/scowl.txt
git rev-parse HEAD >> "$DEST"/scowl.txt
echo >> "$DEST"/scowl.txt
cat scowl.txt >> "$DEST"/scowl.txt
cp -a misc/Makefile.dist "$DEST"/Makefile

tar cfa "$DEST".tar.xz "$DEST"
