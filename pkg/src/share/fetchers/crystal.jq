.[]
	| (.tag_name | rtrimstr("v")) as $version
	| .assets[]
	| if .name | contains(".deb") then empty else . end
	| (.name | capture("^crystal[_-](.+?)-1[_-](?:(?<os>.+?)-)?(?<arch>.+?)\\.")) as $m
	| {
		variant: "Crystal",
		version: $version,
		os: (
				if $m.os == "linux" then
					"linux"
				elif $m.os == "darwin" then
					"darwin"
				elif $m.os == "freebsd" then
					"freebsd"
				else
					# TODO: do not fail, only output to stderr
					"Error: Unknown os: \($m.os) \(.name)\n" | halt_error
				end
			),
			arch: (
				if $m.arch == "i686" then
					"x86"
				elif $m.arch == "x86_64" or $m.arch == "x86-64" then
					"amd64"
				elif $m.arch == "x86_64-bundled" or $m.arch == "universal" then
					empty
				else
					"Error: Unknown arch: \($m.arch)\n" | halt_error
				end
			),
			url: .url,
			created_at,
			download_count
		}
	| "\(.variant)|\(.version)|\(.os)|\(.arch)|\(.url)|\(.created_at)#\(.download_count)" | tostring	