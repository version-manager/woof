import "util" as f;

.[]
	| .name as $version
	| .assets[]
	| if (.name | contains(".tar.zst")) then empty else . end
	| (.name | capture("^lean-(?<version>.+)-(?<os>.+?)\\.")) as $m
	| {
		variant: "Lean",
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
		arch: "amd64",
		url: .browser_download_url,
		created_at,
		download_count
	}
	| "\(.variant)|\(.version)|\(.os)|\(.arch)|\(.url)|\(.created_at)#\(.download_count)" | tostring