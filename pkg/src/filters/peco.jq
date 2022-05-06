import "util" as f;

.[]
	| .tag_name as $version
	| .assets[]
	| (.name | capture("^peco_(?<os>.+)_(?<arch>.+?)\\.")) as $m
	| {
		variant: "Peco",
		version: $version,
		os: (
			if $m.os == "linux" or $m.os == "darwin" then
				$m.os
			elif $m.os == "windows" then
				empty
			else
				f::print_error("Unknown os: \($m.os) (context: \(.name))")
			end
		),
		arch: (
			if $m.arch == "amd64" then
				"x86_64"
			elif $m.arch == "386" then
				"x86"
			elif $m.arch == "arm" or $m.arch == "arm64" then
				empty
			else
				f::print_error("Unknown arch: \($m.arch) (context: \(.name))")
			end
		),
		url: .browser_download_url,
		created_at,
		download_count
	}
	| "\(.variant)|\(.version)|\(.os)|\(.arch)|\(.url)|\(.created_at)#\(.download_count)" | tostring