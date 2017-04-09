# RetroArch for Slackware

This is a series of scripts to package RetroArch for Slackware.
There is one script for each component. These days, the one you should
need is *libretro-RetroArch.sh*.

The following are not required, but will be detected and used by RetroArch (and
possibly other Libretro components) if found:

* [OpenAL](http://slackbuilds.org/libraries/OpenAL/)
* [SDL2](http://slackbuilds.org/development/SDL2/)
* [ffmpeg](http://slackbuilds.org/multimedia/ffmpeg/)
* [p7zip](http://slackbuilds.org/system/p7zip/)
* [pulseaudio](http://slackbuilds.org/audio/pulseaudio/)
* [Vulkan SDK](https://raw.githubusercontent.com/duganchen/my_slackbuilds/master/vulkansdk.SlackBuild)
* [NVidia CG Toolkit](http://slackbuilds.org/graphics/nvidia-cg-toolkit/)

Before each installation or upgrade, clear out your ~/.config/retroarch directory. Then initialize it
with:

	mkdir -p ~/.config/retroarch/{savefile,savestate}

Then, start RetroArch. use the Online Updater to update everything, including the cores, shaders,
assets, etc.

## A Note On GamePad Support

As is the case for many games and emulators, RetroArch needs your gamepad devices to be set up with
the correct permissions. The Arch Wiki has a fairly definitive guide to setting that up:

https://wiki.archlinux.org/index.php/udev

What I do is add my user account to the "games" group:

	gpasswd -a dugan games

And then use the following rules for my favorite devices:

