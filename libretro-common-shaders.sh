#!/usr/bin/env zsh

set -e

REPO=common-shaders
PRGNAM=libretro-$REPO
TMP=${TMP:-/tmp}
PKG=$TMP/package-$REPO
BUILD=1dc

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

CWD=$PWD
VERSION=$(git rev-parse --short HEAD)

# To make porting from here easier:
# http://bazaar.launchpad.net/~libretro/libretro/common-shaders/view/head:/debian/rules
SHADERSPATH=$PKG/usr/share/libretro/shaders
DOCPATH=$PKG/usr/doc/$PRGNAM-$VERSION

mkdir -p $PKG/usr/share/libretro/shaders
find . -type f -maxdepth 1 -exec cp {} $SHADERSPATH \;
find . -type d -maxdepth 1 -exec cp -r {} $SHADERSPATH \;

rm -r $SHADERSPATH/.git
rm -r $SHADERSPATH/docs

mkdir -p $DOCPATH
cp $CWD/docs/README $DOCPATH/
mv $SHADERSPATH/blurs/README.txt $DOCPATH/README-blurs
mv $SHADERSPATH/borders/README $DOCPATH/README-borders
mv $SHADERSPATH/crt/shaders/crt-royale/README.TXT $DOCPATH/README-crt-royale
mv $SHADERSPATH/crt/shaders/crt-royale/THANKS.TXT $DOCPATH/THANKS-crt-royale
rm $SHADERSPATH/crt/shaders/crt-royale/LICENSE.TXT
mv $SHADERSPATH/dithering/shaders/gdapt/README.md $DOCPATH/README-dithering_gdapt
mv $SHADERSPATH/dithering/shaders/mdapt/README.md $DOCPATH/README-dithering_mdapt
mv $SHADERSPATH/handheld/gameboy/README.md $DOCPATH/README-gameboy
mv $SHADERSPATH/handheld/lcd-shader/README.md $DOCPATH/README-lcd-shader
mv $SHADERSPATH/hqx/README.md $DOCPATH/README-hqx
mv $SHADERSPATH/srgb-helpers/README.txt $DOCPATH/README-srgb-helpers
mv $SHADERSPATH/windowed/README.md $DOCPATH/README-windowed

cd $PKG
/sbin/makepkg -l y -c n $TMP/$PRGNAM-$VERSION-noarch-${BUILD}.txz

cd -
rm -rf $PKG
rm -rf $TMP/$REPO
