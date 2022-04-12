import "util" as f;

.
	| to_entries
	| .[]
	| .key as $version
	| .value
	| .stable as $is_stable
	| .files[]
	| if .kind == "archive" then
			.
		else
			empty
		end
	| .
	| {
			variant: "Julia",
			version: $version,
			os: (
				if .os == "linux" then
					"linux"
				elif .os == "freebsd" then
					"freebsd"
				elif .os == "mac" then
					"darwin"
				elif .os == "winnt" then
					empty
				else
					f::print_error("Unknown os: \($m.os) (context: \(.name))")
				end
			),
			arch: (
				if .arch == "x86_64" then
					"amd64"
				elif .arch == "i686" then
					"x86_64"
				elif .arch == "aarch64" then
					"arm64"
				elif .arch == "armv7l" then
					"armv7l"
				elif .arch == "powerpc64le" then
					"ppc64le"
				else
					f::print_error("Unknown arch: \($m.arch) (context: \(.name))")
				end
			),
			url,
			sha256
		}
	| "\(.variant)|\(.version)|\(.os)|\(.arch)|\(.url)" | tostring