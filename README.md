This is a series of scripts to package RetroArch for Slackware.
There is one script for each component.

The following are not required, but will be detected and used by RetroArch (and
possibly other Libretro components) if found:

* [OpenAL](http://slackbuilds.org/libraries/OpenAL/)
* [SDL2](http://slackbuilds.org/development/SDL2/)
* [ffmpeg](http://slackbuilds.org/multimedia/ffmpeg/)
* [p7zip](http://slackbuilds.org/system/p7zip/)
* [pulseaudio](http://slackbuilds.org/audio/pulseaudio/)
* [Vulkan SDK](https://raw.githubusercontent.com/duganchen/my_slackbuilds/master/vulkansdk.SlackBuild)
* [NVidia CG Toolkit](http://slackbuilds.org/graphics/nvidia-cg-toolkit/)

The DosBox core is also set to build with FluidSynth support.

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

Before each installation or upgrade, clear out your ~/.config/retroarch directory. Then initialize it
with:

	mkdir -p ~/.config/retroarch/{savefile,savestate}

Then, start RetroArch. use the Online Updater to update everything except the Cores, Core Info files,
thumbnails and GLSL shaders.

Use the included SlackBuilds to install the cores. More cores are on SlackBuilds.org, and you may have
to adjust your ~/.config/retroarch/retroarch.cfg to use them.
