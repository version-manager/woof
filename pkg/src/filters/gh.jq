.[]
	| .tag_name as $version
	| .assets[]
	| if (.name | contains(".deb")) or (.name | contains(".rpm")) then empty else . end 
	| (.name | capture("^gh_(?<version>.+?)_(?<os>.+?)_(?<arch>.+?)\\.")) as $m
	| {
			variant: "gh",
			version: $version,
			os: (
				if $m.os == "linux" then
					"linux"
				elif $m.os == "macOS" then
					"darwin"
				elif $m.os == "windows" then
					empty
				else
					# TODO: do not fail, only output to stderr
					"Error: Unknown os: \($m.os) \(.name)\n" | halt_error
				end
			),
			arch: (
				if $m.arch == "386" then
					"x86"
				elif $m.arch == "amd64" then
					"amd64"
				elif $m.arch == "arm64" then
					"arm64"
				elif $m.arch == "armv6" then
					"armv6"
				else
					"Error: Unknown arch: \($m.arch)\n" | halt_error
				end
			),
			url: .browser_download_url,
			created_at,
			download_count
		}
	| "\(.variant)|\(.version)|\(.os)|\(.arch)|\(.url)|\(.created_at)#\(.download_count)" | tostring