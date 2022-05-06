import "util" as f;

.[]
	| .tag_name as $version
	| .assets[]
	| (.name | capture("^ninja-(?<os>.+?)\\.")) as $m
	| 
	{
		variant: "Ninja",
		version: $version,
		os: (
			if $m.os == "linux" then
				$m.os
			elif $m.os == "mac" then
				"darwin"
			elif $m.os == "win" then
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