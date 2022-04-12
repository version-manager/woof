import "util" as f;

.[]
	| .tag_name as $version
	| .assets[]
	| (.name | capture("bin(.+?)for-(?<os>.+?)[.-](?<arch>64-bit)?")) as $m
	| {
		variant: "Elm",
		version: $version,
		os: (
				if $m.os == "linux" then
					"linux"
				elif $m.os == "mac" then
					"darwin"
				elif $m.os == "windows" then
					empty
				else
					f::print_error("Unknown os: \($m.os) (context: \(.name))")
				end
			),
		arch: (
				if $m.arch == "64-bit" then
					"amd64"
				else
					"x86_64"
				end
			) ,
		url: .browser_download_url,
		created_at,
		download_count
	}
	| "\(.variant)|\(.version)|\(.os)|\(.arch)|\(.url)|\(.created_at)#\(.download_count)" | tostring