import "util" as f;

# TODO: make 'haxe', 'fstar', etc. a special case

.[]
	| (.tag_name | ltrimstr("v") | ltrimstr("V") # fstar
		| rtrimstr("v")) as $version
	| .assets[]
	| if
		(.name | contains(".deb")) or
		(.name | contains(".rpm")) or
		(.name | contains(".tar.zst")) or
		(.name | contains(".tar.xz")) or # please
		(.name | contains(".sha")) or
		(.name | contains(".zip")) or # helm
		(.name | contains(".asc")) then empty else . end
	| (.name | capture($global_regex)) as $m
	| {
		variant: $global_variant,
		version: $version,
		os: (
				if $m.os == "linux" or $m.os == "Linux" then
					"linux"
				elif $m.os == "linux" or $m.os == "linux64" or $m.os == "linux32" then # haxe
					"linux"
				elif $m.os == "darwin" or $m.os == "Darwin" or $m.os == "macOS" or $m.os == "macos" or $m.os == "osx" or $m.os == "mac" then
					"darwin"
				elif $m.os == "windows" or $m.os == "Windows" or $m.os == "windows32" or $m.os == "win" then
					empty
				elif $m.os == "win64" then # haxe
					empty
				elif $m.os == "freebsd" then
					"freebsd"
				elif $m.os == "uni-1" then # neko
					empty
				elif $m.os == "installer" or $m.os == "raspi" then # haxe
					empty
				else
					f::print_error("Unknown os: \($m.os) (context: \(.name))")
				end
			),
			arch: (
				if $m.arch == "i686" or $m.arch == "386" then
					"x86"
				elif $m.arch == "x86_64" or $m.arch == "x86-64" or $m.arch == "amd64" or $m.arch == "64-bit" then
					"x86_64"
				elif $m.arch == "64" then # neko
					"x86_64"
				elif $m.arch == "64-bit" then # elm
					"x86_64"
				elif $m.arch == "arm" or "arm64" or $m.arch == "aarch64" then
					"arm64"
				elif $m.arch == "arm7" or $m.arch == "arm5" or $m.arch == "arm6" then # earthly
					empty
				elif $m.arch == "armv6" then # gh
					empty
				elif $m.arch == "ppc64le" or $m.arch == "s390x" then # helm
					empty
				elif $m.arch == "x86_64-bundled" or $m.arch == "universal" then # crystal
					empty
				elif $m.os == "linux32" then # haxe
					"x86"
				elif $m.arch == null or $m.arch == "" then
					if $global_default_arch == "" then
						f::print_error("Default arch not defined (context: \(.name))")
					else
						$global_default_arch
					end
				else
					f::print_error("Unknown arch: \($m.arch) (context: \(.name))")
				end
			),
			url: .browser_download_url,
			created_at,
			download_count
		}
	| "\(.variant)|v\(.version)|\(.os)|\(.arch)|\(.url)|\(.created_at)#\(.download_count)" | tostring
