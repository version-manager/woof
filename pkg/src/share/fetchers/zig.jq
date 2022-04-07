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
					# TODO: do not fail, only output to stderr
					"Error: Unknown os: \($m.os)\n" | halt_error
				end
			),
			arch: (
				if $m.arch == "i386" or $m.arch == "x86_64" then
					"amd64"
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
	| "\(.variant)|\(.version)|\(.os)|\(.arch)|\(.url)" | tostring