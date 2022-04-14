import "util" as f;

.[]
	| .tag_name as $version
	| .assets[]
	| (.name | capture("^v_(?<os>.+?)(?:_(?<arch>arm64))?\\.")) as $m
	| {
			variant: "V",
			version: $version,
			os: (
				if $m.os == "linux" then
					$m.os
				elif $m.os == "macos" then
					"darwin"
				elif $m.os == "windows" or $m.os == "windows32" then
					empty
				else
					f::print_error("Unknown os: \($m.os) (context: \(.name))")
				end
			),
			arch: (
				if $m.arch == null then
					"amd64"
				elif $m.arch == "arm64" then
					$m.arch
				else
					f::print_error("Unknown arch: \($m.arch) (context: \(.name))")
				end
			),
			url: .browser_download_url,
			created_at,
			download_count
		}
	| "\(.variant)|\(.version)|\(.os)|\(.arch)|\(.url)|\(.created_at)#\(.download_count)" | tostring