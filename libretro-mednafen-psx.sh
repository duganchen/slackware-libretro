#!/usr/bin/env bash

set -e

REPO=beetle-psx-libretro
CORE=mednafen_psx_libretro
PRGNAM=libretro-mednafen-psx
TMP=${TMP:-/tmp}
PKG=$TMP/package-${REPO}
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

CWD=`pwd`
VERSION=`git rev-parse --short HEAD`

# Download the core info file from the libretro-super project directly into the package
mkdir -p $PKG/usr/lib$LIBDIRSUFFIX/libretro/info
cd $PKG/usr/lib$LIBDIRSUFFIX/libretro/info
curl -O https://raw.githubusercontent.com/libretro/libretro-super/master/dist/info/${CORE}.info

# build and install the core
cd $CWD
CFLAGS="$SLKCFLAGS" CXXFLAGS="$SLKCFLAGS" make
cp $CORE.so $PKG/usr/lib$LIBDIRSUFFIX/libretro

find $PKG -print0 | xargs -0 file | grep -e "executable" -e "shared object" | grep ELF \
  | cut -f 1 -d : | xargs strip --strip-unneeded 2> /dev/null || true

cd $PKG
/sbin/makepkg -l y -c n $TMP/$PRGNAM-$VERSION-$ARCH-${BUILD}.txz
