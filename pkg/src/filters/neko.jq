import "util" as f;

.[]
	| .name as $version
	| .assets[]
	| (.name | capture("^neko-(?<version>.+?)-(?<os>.+?)(?<arch>(?:64)?)\\.")) as $m
	| {
			variant: "Neko",
			version: $version,
			os: (
				if $m.os == "linux" then
					"linux"
				elif $m.os == "osx" then
					"darwin"
				elif $m.os == "win" or $m.os == "uni-1" then
					empty
				else
					f::print_error("Unknown os: \($m.os) (context: \(.name))")
				end
			),
			arch: (
				if $m.arch == "64" then
					"x86_64"
				elif $m.arch == "" then
					"x86"
				else
					f::print_error("Unknown arch: \($m.arch) (context: \(.name))")
				end
			),
			url: .browser_download_url,
			created_at,
			download_count
		}
	| "\(.variant)|\(.version)|\(.os)|\(.arch)|\(.url)|\(.created_at)#\(.download_count)" | tostring