This is intended to be a series of scripts to package RetroArch for Slackware.
There is one script for each component.

The [NVidia CG Toolkit](http://slackbuilds.org/graphics/nvidia-cg-toolkit/) is
a requirement for both RetroArch and for common-shaders.

The following are not required, but will be detected and used by RetroArch (and
possibly other Libretro components) if found:

* [OpenAL](http://slackbuilds.org/libraries/OpenAL/)
* [SDL2](http://slackbuilds.org/development/SDL2/)
* [ffmpeg](http://slackbuilds.org/multimedia/ffmpeg/)
* [p7zip](http://slackbuilds.org/system/p7zip/)
* [pulseaudio](http://slackbuilds.org/audio/pulseaudio/)

Each script is named "libretro-<PACKAGE>.sh". Running it will clone the master
branch of the package's git repository, build it into a Slackware package named
PACKAGE and versioned with the git revision's short hash, and do its work in
$TMP (which is /tmp unless you've set it otherwise). This process should be
familiar to Slackware users who use SlackBuild scripts.

The following commands will build the latest version of each component, and
then either upgrade or install it (as appropriate):

	rm /tmp/libretro-* cd /path/to/slackware-libretro find -name "*.sh" -exec
	{} \; upgradepkg --reinstall --install-new /tmp/libretro-*.txz
