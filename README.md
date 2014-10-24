This is intended to be a series of scripts to package RetroArch for Slackware.

It is influenced by the Debian package-building scripts:
https://code.launchpad.net/~libretro/libretro

Set the paths in your config file as below. If you're on an x86 system,
then change "/usr/lib64" to "/usr/lib.":

	video_shader_dir = "/usr/share/libretro/shaders"
	video_filter_dir = "/usr/lib64/retroarch/filters/video"
	audio_filter_dir = "/usr/lib64/retroarch/filters/audio"
	assets_directory = "/usr/share/libretro/assets"
	overlay_directory = "/usr/share/libretro/overlays"
	libretro_directory = "/usr/lib64/libretro"
	libretro_info_path = "/usr/lib64/libretro/info"
	joypad_autoconfig_dir = "/usr/share/libretro/autoconfig"
