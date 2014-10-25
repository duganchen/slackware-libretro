#!/usr/bin/env bash

set -e

REPO=Dinothawr
CORE=dinothawr_libretro
PRGNAM=libretro-$REPO
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

# Download the core info file from the libretro-super project directly into the package
mkdir -p $PKG/usr/lib$LIBDIRSUFFIX/libretro/info
cd $PKG/usr/lib$LIBDIRSUFFIX/libretro/info
curl -O https://raw.githubusercontent.com/libretro/libretro-super/master/dist/info/${CORE}.info

# build and install the core
cd $CWD
CFLAGS="$SLKCFLAGS" CXXFLAGS="$SLKCFLAGS" make
mkdir -p $PKG/usr/lib$LIBDIRSUFFIX/libretro
cp ${CORE}.so $PKG/usr/lib$LIBDIRSUFFIX/libretro

# data files
mkdir -p $PKG/usr/share/dinothawr/data
cp -r dinothawr/* $PKG/usr/share/dinothawr/data/
rm -f $PKG/usr/share/dinothawr/data/*.glsl* *.png *.cfg
rm -f $PKG/usr/share/dinothawr/data/*.png *.cfg
rm -f $PKG/usr/share/dinothawr/data/*.*.cfg

# icons
mkdir -p $PKG/usr/share/icons/hicolor/{48x48,64x64,72x72,96x96}/apps
cp android/icon48x48.png $PKG/usr/share/icons/hicolor/48x48/apps/dinothawr.png
cp android/icon64x64.png $PKG/usr/share/icons/hicolor/64x64/apps/dinothawr.png
cp android/icon72x72.png $PKG/usr/share/icons/hicolor/72x72/apps/dinothawr.png
cp android/icon96x96.png $PKG/usr/share/icons/hicolor/96x96/apps/dinothawr.png

# shaders
mkdir -p $PKG/usr/share/dinothawr/shaders
cp dinothawr/*.glsl* $PKG/usr/share/dinothawr/shaders/

# overlays
mkdir -p $PKG/usr/share/dinothawr/overlays
cp dinothawr/*.cfg $PKG/usr/share/dinothawr/overlays/
cp dinothawr/*.png $PKG/usr/share/dinothawr/overlays/

# Note the following downloads from Launchpad. I decided to just download
# them instead of cloning the repository, because Slackware doesn't include
# bzr.

# dinothawr script
mkdir -p $PKG/usr/bin
curl http://bazaar.launchpad.net/~libretro/libretro/dinothawr-libretro-debian/download/head:/dinothawr.sh-20140817024106-8j2yxnodbvcvgg9g-1/dinothawr.sh -o $PKG/usr/bin/dinothawr
if [ "$ARCH" = "x86_64" ]; then
 	sed -i 's/usr\/lib/usr\/lib64/g' $PKG/usr/bin/dinothawr
fi
chmod +x $PKG/usr/bin/dinothawr

# config file
mkdir -p $PKG/etc
curl http://bazaar.launchpad.net/~libretro/libretro/dinothawr-libretro-debian/download/head:/dinothawr.cfg-20140816233845-99rz81ez16eppgif-7/dinothawr.cfg -o $PKG/etc/dinothawr.cfg

# desktop entry
mkdir -p $PKG/usr/share/applications
curl http://bazaar.launchpad.net/~libretro/libretro/dinothawr-libretro-debian/download/head:/dinothawr.desktop-20140816233845-99rz81ez16eppgif-8/dinothawr.desktop -o $PKG/usr/share/applications/dinothawr.desktop

find $PKG -print0 | xargs -0 file | grep -e "executable" -e "shared object" | grep ELF \
  | cut -f 1 -d : | xargs strip --strip-unneeded 2> /dev/null || true

cd $PKG
/sbin/makepkg -l y -c n $TMP/$PRGNAM-$VERSION-$ARCH-${BUILD}.txz
