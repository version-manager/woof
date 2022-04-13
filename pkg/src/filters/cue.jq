import "util" as f;

.[]
	| .tag_name as $version
	| .assets[]
	| (.name | capture("^cue_(?<version>.+?)_(?<os>.+?)_(?<arch>.+?)\\.")) as $m
	| {
			variant: "Cue",
			version: $version,
			os: (
				if $m.os == "Linux" or $m.os == "linux" then
					"linux"
				elif $m.os == "Darwin" or $m.os == "darwin" then
					"darwin"
				elif $m.os == "Windows" or $m.os == "windows" then
					empty
				else
					f::print_error("Unknown os: \($m.os) (context: \(.name))")
				end
			),
			arch: (
				if $m.arch == "x86_64" or $m.arch == "amd64" then
					"amd64"
				elif $m.arch == "arm64" then
					"arm64"
				else
					f::print_error("Unknown arch: \($m.arch) (context: \(.name))")
				end
			),
			url: .browser_download_url,
			created_at,
			download_count
		}
	| "\(.variant)|\(.version)|\(.os)|\(.arch)|\(.url)|\(.created_at)#\(.download_count)" | tostring