import "util" as f;

.[]
	| .tag_name as $version
	| .assets[]
	| (.name | capture("^earthly-(?<os>.+)-(?<arch>.+)")) as $m
	| {
			variant: "Earthly",
			version: $version,
			os: (
				if $m.os == "darwin" or $m.os == "linux" then
					$m.os
				elif $m.os == "windows" then
					empty
				else
					f::print_error("Unknown os: \($m.os) (context: \(.name))")
				end
			),
			arch: (
				if $m.arch == "amd64" then
					"amd64"
				elif $m.arch == "arm64" then
					"arm64"
				elif $m.arch == "arm7" or $m.arch == "arm5" or $m.arch == "arm6" then
					empty # FIXME
				else
					f::print_error("Unknown arch: \($m.arch) (context: \(.name))")
				end
			),
			url: .browser_download_url,
			created_at,
			download_count
		}
	| "\(.variant)|\(.version)|\(.os)|\(.arch)|\(.url)|\(.created_at)#\(.download_count)" | tostring