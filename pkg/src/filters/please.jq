import "util" as f;

.[]
	| .tag_name as $version
	| .assets[]
	| if (.name | contains(".sha")) or (.name | contains(".asc")) or (.name | contains(".deb")) or (.name | contains(".tar.gz")) then empty else . end 
	| (.name | capture("^please_(?:(?<type>servers|shim|tools)_)?(?<version>.+?)_(?<os>.+?)_(?<arch>.+?)\\.")) as $m
	| if $m.type != null then empty else . end
	| {
			variant: "Please",
			version: $version,
			os: (
				if $m.os == "darwin" or $m.os == "freebsd" or $m.os == "linux" then
					$m.os
				else
					f::print_error("Unknown os: \($m.os) (context: \(.name))")
				end
			),
			arch: (
				if $m.arch == "amd64" or $m.arch == "arm64" then
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