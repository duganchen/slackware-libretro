This is a series of scripts to package RetroArch for Slackware.
There is one script for each component.

The [NVidia CG Toolkit](http://slackbuilds.org/graphics/nvidia-cg-toolkit/) is
a requirement for both RetroArch and for common-shaders.

RetroArch needs libusb to be at least 1.0.16, which is newer than the one in
Slackware 14.1.

The following are not required, but will be detected and used by RetroArch (and
possibly other Libretro components) if found:

* [OpenAL](http://slackbuilds.org/libraries/OpenAL/)
* [SDL2](http://slackbuilds.org/development/SDL2/)
* [ffmpeg](http://slackbuilds.org/multimedia/ffmpeg/)
* [p7zip](http://slackbuilds.org/system/p7zip/)
* [pulseaudio](http://slackbuilds.org/audio/pulseaudio/)

The DosBox core is also set to build with FluidSynth support.

Each script is named "libretro-PACKAGE.sh". Running it will clone the master
branch of the package's git repository, build it into a Slackware package named
PACKAGE and versioned with the git revision's short hash, and do its work in
$TMP (which is /tmp unless you've set it otherwise). This process should be
familiar to Slackware users who use SlackBuild scripts.

The following commands will build the latest version of each component, and
then either upgrade or install it (as appropriate):

	rm /tmp/libretro-*
	cd /path/to/slackware-libretro
	find -name "*.sh" -exec {} \;
	upgradepkg --reinstall --install-new /tmp/libretro-*.txz

By default, RetroArch uses udev for gamepad support, and thus requires the
udev joystick devices to be user-readable. They are only root-readable by
default. You need a udev rule to set the permissions properly. One
implementation is to create a file named */etc/udev/rules.d/99-joystick.rules*,
containing the following:

    KERNEL=="event[0-9]*", ENV{ID_BUS}=="?*", ENV{ID_INPUT_JOYSTICK}=="?*", GROUP="games", MODE="0660"
	KERNEL=="js[0-9]*", ENV{ID_BUS}=="?*", ENV{ID_INPUT_JOYSTICK}=="?*", GROUP="games", MODE="0664"

Then add your user account to the games group:

	gpasswd -a games user

On your first run, use the Online Updater to update everything except the Core and Core Info files.
Use the included SlackBuilds to install the cores. If you want to install the cores that were
prebuilt upstream on an Ubuntu system instead, just edit your CFG file accordingly.
