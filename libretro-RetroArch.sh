#!/usr/bin/env zsh

set -e

TMP=${TMP:-/tmp}
USER=libretro
REPO=RetroArch
PKG=$TMP/package-${USER}-${REPO}
BUILD=1dc

if [[ -z $ARCH ]]; then
	case $( uname -m ) in
		i?86) ARCH=i486 ;;
		arm*) ARCH=arm ;;
		*) ARCH=$( uname -m ) ;;
	esac
fi

if [[ $ARCH == "i486" ]]; then
	SLKCFLAGS="-O2 -march=i486 -mtune=i686"
	LIBDIRSUFFIX=""
elif [[ $ARCH == "i686" ]]; then
	SLKCFLAGS="-O2 -march=i686 -mtune=i686"
	LIBDIRSUFFIX=""
elif [[ $ARCH == "x86_64" ]]; then
	SLKCFLAGS="-O2 -fPIC"
	LIBDIRSUFFIX="64"
else
	SLKCFLAGS="-O2"
	LIBDIRSUFFIX=""
fi


rm -rf $PKG
rm -rf $TMP/${REPO}

mkdir -p $PKG
cd $TMP

HEADER="Accept: application/vnd.github.v3.raw+json"
PARSER=$(cat <<-END
import json
import sys
tags = json.load(sys.stdin)
print tags[0]["name"]
END
)
ENDPOINT="https://api.github.com/repos/${USER}/${REPO}/tags"
TAG="$(curl -H $HEADER $ENDPOINT | python -c $PARSER)"
VERSION=$(echo $TAG | cut -c 2-)

git clone https://github.com/${USER}/${REPO}.git
cd $REPO
git checkout $TAG
git clean -f -d -x

chown -R root:root .
find -L . \
 \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
  -o -perm 511 \) -exec chmod 755 {} \; -o \
 \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
  -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

FILTERS="\/usr\/lib$LIBDIRSUFFIX\/retroarch\/filters"
sed -i "s/# \(\(video\)_filter_dir =\)/\1 $FILTERS\/\2/" retroarch.cfg
sed -i "s/# \(\(audio\)_filter_dir =\)/\1 $FILTERS\/\2/" retroarch.cfg

sh fetch-submodules.sh

CWD=$PWD
CFLAGS=$SLKCFLAGS \
	CXXFLAGS="$SLKCFLAGS" \
	./configure \
	--prefix=/usr

make
make -C gfx/video_filters
make -C libretro-common/audio/dsp_filters
make DESTDIR=$PKG PREFIX=/usr install
mv $PKG/usr/share/man $PKG/usr
mkdir -p $PKG/usr/doc/RetroArch-$VERSION
cp $CWD/[A-Z][A-Z]* $PKG/usr/doc/RetroArch-$VERSION
mkdir -p $PKG/usr/share/applications
cp $CWD/retroarch.desktop $PKG/usr/share/applications
mkdir -p $PKG/usr/lib$LIBDIRSUFFIX/retroarch/filters/video
cp $CWD/gfx/video_filters/*.so $PKG/usr/lib$LIBDIRSUFFIX/retroarch/filters/video
cp $CWD/gfx/video_filters/*.filt $PKG/usr/lib$LIBDIRSUFFIX/retroarch/filters/video
mkdir -p $PKG/usr/lib$LIBDIRSUFFIX/retroarch/filters/audio
cp $CWD/libretro-common/audio/dsp_filters/*.so $PKG/usr/lib$LIBDIRSUFFIX/retroarch/filters/audio
cp $CWD/libretro-common/audio/dsp_filters/*.dsp $PKG/usr/lib$LIBDIRSUFFIX/retroarch/filters/audio

find $PKG -print0 | xargs -0 file | grep -e "executable" -e "shared object" | grep ELF \
  | cut -f 1 -d : | xargs strip --strip-unneeded 2> /dev/null || true

for m in $PKG/usr/man/**/*.[0-9]; do
	gzip -9 $m
done

cd $PKG
/sbin/makepkg -l y -c n $TMP/${USER}-${REPO}-${VERSION}-${ARCH}-${BUILD}.txz
