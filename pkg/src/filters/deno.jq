import "util" as f;

.[]
	| .tag_name as $version
	| (($version | split("."))[0] | ltrimstr("v") | tonumber) as $version_major
	| (($version | split("."))[1] | tonumber) as $version_minor
		# The patch release may include the rc (i.g. '-rc3'). We remove that just
		# so $version_patch can be a number. Release candidates are still downloadable
	| (($version[0:$version | rindex("-")] | split("."))[2] | tonumber) as $version_patch 
	| .assets[] 
	| (if $version_major == 0 and $version_minor == 35 and $version_patch == 0
			or $version_major == 0 and $version_minor <= 35 then
			.name | capture("^deno_(?<os>.+?)_(?<arch>.+?)\\.")
		else
			.name | capture("^deno[_-](?<arch>.+?_64?)[_-](?<os>.+?)\\.")
		end) as $m
	| {
			variant: "Deno",
			version: $version,
			os: (
				if $m.os == "unknown-linux-gnu" or $m.os == "linux" then
					"linux"
				elif $m.os == "apple-darwin" or $m.os == "osx" or $m.os == "mac" then
					"darwin"
				elif $m.os == "win" or $m.os == "pc-windows-msvc" then
					empty
				else
					f::print_error("Unknown os: \($m.os) (context: \(.name))")				end
			),
			arch: (
				if $m.arch == "x64" or $m.arch == "x86_64" then
					"amd64"
				else
					f::print_error("Unknown arch: \($m.arch) (context: \(.name))")
				end
			),
			url: .browser_download_url,
			created_at,
			download_count
		}
	| "\(.variant)|\(.version)|\(.os)|\(.arch)|\(.url)|\(.created_at)#\(.download_count)" | tostring
