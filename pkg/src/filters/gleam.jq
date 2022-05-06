import "util" as f;

.[]
	| .tag_name as $version
	| .assets[]
	| if (.name | contains(".sha")) then empty else . end 
	| (.name | capture("^gleam-(?<version>.+)-(?<os>linux|macos)(?:-(?<arch>.+?))?\\.")) as $m
	| {
			variant: "Gleam",
			version: $version,
			os: $m.os,
			arch: (
				if $m.arch == "amd64" then
					"x86_64"
				elif $m.arch == "arm64" then
					"arm64"
				elif $m.arch == null then
					"x86_64" # FIXME possible bug
				else
					f::print_error("Unknown arch: \($m.arch) (context: \(.name))")
				end
			),
			url: .browser_download_url,
			created_at,
			download_count
		}
	| "\(.variant)|\(.version)|\(.os)|\(.arch)|\(.url)|\(.created_at)#\(.download_count)" | tostring