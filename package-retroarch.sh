#!/usr/bin/env bash

set -e

TMP=${TMP:-/tmp}

PKG_ROOT=$TMP/package-libretro
SRC_ROOT=$TMP/libretro

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

rm -rf $PKG_ROOT
rm -rf $SRC_ROOT

mkdir -p $PKG_ROOT
mkdir -p $SRC_ROOT

# Start with RetroArch

PKG=$PKG_ROOT/RetroArch
mkdir -p $PKG
cd $SRC_ROOT
git clone https://github.com/libretro/RetroArch.git
cd RetroArch
CWD=`pwd`
VERSION=`git rev-parse --short HEAD`
CFLAGS="$SLKCFLAGS" \
CXXFLAGS="$SLKCFLAGS" \
./configure \
  --prefix=/usr \
  --enable-lakka \
  --enable-cg
make
make -C gfx/filters
make -C audio/filters
make DESTDIR=$PKG PREFIX=/usr install
mv $PKG/usr/share/man $PKG/usr
mkdir -p $PKG/usr/doc
cp $CWD/AUTHORS $PKG/usr/doc
mkdir -p $PKG/usr/share/applications
cp $CWD/debian/retroarch.desktop $PKG/usr/share/applications
mkdir -p $PKG/usr/lib$LIBDIRSUFFIX/retroarch/filters/video
cp $CWD/gfx/filters/*.so $PKG/usr/lib$LIBDIRSUFFIX/retroarch/filters/video
cp $CWD/gfx/filters/*.filt $PKG/usr/lib$LIBDIRSUFFIX/retroarch/filters/video
mkdir -p $PKG/usr/lib$LIBDIRSUFFIX/retroarch/filters/audio
cp $CWD/audio/filters/*.so $PKG/usr/lib$LIBDIRSUFFIX/retroarch/filters/audio
cp $CWD/audio/filters/*.dsp $PKG/usr/lib$LIBDIRSUFFIX/retroarch/filters/audio

find $PKG -print0 | xargs -0 file | grep -e "executable" -e "shared object" | grep ELF \
  | cut -f 1 -d : | xargs strip --strip-unneeded 2> /dev/null || true

find $PKG/usr/man -type f -exec gzip -9 {} \;
for i in $( find $PKG/usr/man -type l ) ; do ln -s $( readlink $i ).gz $i.gz ; rm $i ; done

cd $PKG
/sbin/makepkg -l y -c n $TMP/RetroArch-$VERSION-$ARCH-${BUILD}.txz
