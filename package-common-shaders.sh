#!/usr/bin/env bash

set -e

REPO=common-shaders
TMP=${TMP:-/tmp}
PKG=$TMP/package-$REPO
BUILD=1

rm -rf $PKG
rm -rf $TMP/$REPO

mkdir -p $PKG
cd $TMP
git clone https://github.com/libretro/${REPO}.git
cd $REPO

chown -R root:root .
find -L . \
 \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
  -o -perm 511 \) -exec chmod 755 {} \; -o \
 \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
  -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

CWD=`pwd`
VERSION=`git rev-parse --short HEAD`

mkdir -p $PKG/usr/share/libretro/shaders
find . -type f -maxdepth 1 -exec cp {} $PKG/usr/share/libretro/shaders \;
find . -type d -maxdepth 1 -not -name ".*" -exec cp -r {} $PKG/usr/share/libretro/shaders \;

cd $PKG
/sbin/makepkg -l y -c n $TMP/$REPO-$VERSION-noarch-${BUILD}.txz
