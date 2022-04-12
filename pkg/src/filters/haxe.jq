import "util" as f;

.[]
	| .tag_name as $version
	| .assets[]
	| (.name | capture("^haxe-.+-(?<os>.+?)\\.")) as $m
	| {
		variant: "Haxe",
		version: $version,
		os: (
				if $m.os == "linux" or $m.os == "linux64" or $m.os == "linux32" then
					"linux"
				elif $m.os == "osx" then
					"darwin"
				elif $m.os == "win" or $m.os == "win64" or $m.os == "installer" or $m.os == "raspi" then
					empty
				else
					f::print_error("Unknown os: \($m.os) (context: \(.name))")
				end
			),
		arch: (
				if $m.os == "linux32" then
					"x86_64"
				else
					"amd64"
				end
			) ,
		url: .browser_download_url,
		created_at,
		download_count
	}
	| "\(.variant)|\(.version)|\(.os)|\(.arch)|\(.url)|\(.created_at)#\(.download_count)" | tostring	