import "util" as f;

.[]
	| .name as $version
	| if .name | startswith("v20") | not then empty else . end
	| .assets[]
	| (.name | capture("^fstar_(?<version>.+)_(?<os>.+)_x86_64\\.")) as $m
	| {
		variant: "FStar",
		version: $version,
		os: (
			if $m.os == "Linux" then
				"linux"
			elif $m.os == "Windows" or $m.os == "Darwin" then
				empty
			else
				f::print_error("Unknown os: \($m.os) (context: \(.name))")
			end
		),
		arch: "x86_64",
		url: .browser_download_url,
		created_at,
		download_count
	}
	| "\(.variant)|\(.version)|\(.os)|\(.arch)|\(.url)|\(.created_at)#\(.download_count)" | tostring