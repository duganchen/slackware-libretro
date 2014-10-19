#!/usr/bin/env bash

# Based on:
# http://bazaar.launchpad.net/~libretro/libretro/retroarch-assets-debian/view/head:/rules

set -e

REPO=retroarch-assets
TMP=${TMP:-/tmp}
PKG=$TMP/package-$REPO
BUILD=1

# Automatically determine the architecture we're building on:
if [ -z "$ARCH" ]; then
  case "$( uname -m )" in
    i?86) ARCH=i486 ;;
    arm*) ARCH=arm ;;
    # Unless $ARCH is already set, use uname -m for all other archs:
       *) ARCH=$( uname -m ) ;;
  esac
fi

if [ "$ARCH" = "i486" ]; then
  SLKCFLAGS="-O2 -march=i486 -mtune=i686"
  LIBDIRSUFFIX=""
elif [ "$ARCH" = "i686" ]; then
  SLKCFLAGS="-O2 -march=i686 -mtune=i686"
  LIBDIRSUFFIX=""
elif [ "$ARCH" = "x86_64" ]; then
  SLKCFLAGS="-O2 -fPIC"
  LIBDIRSUFFIX="64"
else
  SLKCFLAGS="-O2"
  LIBDIRSUFFIX=""
fi

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

mkdir -p $PKG/usr/share/libretro/assets
find . -type d  -maxdepth 1 -not -name ".*" -exec cp -r {} $PKG/usr/share/libretro/assets \;
find $PKG/usr/share/libretro/assets -type d -name src -prune -exec rm -r {} \;
rm -rf

cd $PKG
/sbin/makepkg -l y -c n $TMP/$REPO-$VERSION-$ARCH-${BUILD}.txz
