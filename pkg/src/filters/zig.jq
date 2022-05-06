import "util" as f;

.
	| to_entries
	| .[]
	| .key as $version
	| if $version == "master" then
			empty
		else
			.
		end
	| .value
	| .date as $release_date
	| to_entries
	| .[]
	| if .key == "date" or .key == "docs" or .key == "notes" or .key == "src" then
			empty
		else
			.
		end
	| (.key | capture("^(?<arch>.+)-(?<os>.+)")) as $m
	| {
			variant: "Zig",
			version: $version,
			os: (
				if $m.os == "linux" then
					"linux"
				elif $m.os == "freebsd" then
					"freebsd"
				elif $m.os == "macos" then
					"darwin"
				elif $m.os == "windows" then
					empty
				else
					f::print_error("Unknown os: \($m.os) (context: \(.name))")
				end
			),
			arch: (
				if $m.arch == "i386" then
					"x86"
				elif $m.arch == "x86_64" then
					"x86_64"
				elif $m.arch == "aarch64" then
					"arm64"
				elif $m.arch == "armv7a" then
					"armv7l"
				elif $m.arch == "armv6kz" then
					"armv6"
				elif $m.arch == "riscv64" then
					"riscv64"
				else
					"Error: Unknown arch: \($m.arch)\n" | halt_error
				end
			),
			url: .value.tarball
		}
	| "\(.variant)|v\(.version)|\(.os)|\(.arch)|\(.url)" | tostring