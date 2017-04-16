# RetroArch for Slackware

This is a series of scripts to package RetroArch for Slackware.
These days, the only one you need need is *libretro-RetroArch.sh*.

The following are not required, but will be detected and used by RetroArch (and
possibly other Libretro components) if found:

* [OpenAL](http://slackbuilds.org/libraries/OpenAL/)
* [SDL2](http://slackbuilds.org/development/SDL2/)
* [ffmpeg](http://slackbuilds.org/multimedia/ffmpeg/)
* [p7zip](http://slackbuilds.org/system/p7zip/)
* [pulseaudio](http://slackbuilds.org/audio/pulseaudio/)
* [Vulkan SDK](https://raw.githubusercontent.com/duganchen/my_slackbuilds/master/vulkansdk.SlackBuild)
* [NVidia CG Toolkit](http://slackbuilds.org/graphics/nvidia-cg-toolkit/)

Use the Online Updater to update everything except the assets.

## A Note On GamePad Support

As is the case for many games and emulators, RetroArch needs your gamepad devices to be set up with
the correct permissions. The Arch Wiki has a fairly definitive guide to setting that up:

https://wiki.archlinux.org/index.php/udev
