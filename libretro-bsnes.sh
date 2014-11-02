#!/usr/bin/env bash

set -e

REPO=bsnes-libretro
PRGNAM=libretro-bsnes
CORE=bsnes
TMP=${TMP:-/tmp}
PKG=$TMP/package-$REPO
BUILD=1dc

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

# Download the core info files from the libretro-super project directly into the package
mkdir -p $PKG/usr/lib$LIBDIRSUFFIX/libretro/info
cd $PKG/usr/lib$LIBDIRSUFFIX/libretro/info
for PROFILE in accuracy balanced performance; do
	curl -O https://raw.githubusercontent.com/libretro/libretro-super/master/dist/info/${CORE}_${PROFILE}_libretro.info
done

# build and install the cores
cd $CWD
for PROFILE in accuracy balanced performance; do
	CFLAGS="$SLKCFLAGS" CXXFLAGS="$SLKCFLAGS" make profile=$PROFILE ui=target-libretro
	mv out/${CORE}_libretro.so $PKG/usr/lib$LIBDIRSUFFIX/libretro/${CORE}_${PROFILE}_libretro.so
	make clean
done

find $PKG -print0 | xargs -0 file | grep -e "executable" -e "shared object" | grep ELF \
  | cut -f 1 -d : | xargs strip --strip-unneeded 2> /dev/null || true

cd $PKG
/sbin/makepkg -l y -c n $TMP/$PRGNAM-$VERSION-$ARCH-${BUILD}.txz
