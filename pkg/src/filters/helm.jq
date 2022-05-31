import "util" as f;

.[]
	| .tag_name as $version
	| .assets[]
	| if (.name | contains(".zip")) or (.name | contains("sha256")) then empty else . end 
	| (.name | capture("^helm-(.*)-(?<os>.+)-(?<arch>.+?)\\.")) as $m
	| {
		variant: "Helm",
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
		arch: (
			if $m.arch == "amd64" then
				"x86_64"
			elif $m.arch == "386" then
				"x86"
			elif $m.arch == "ppc64le" or $m.arch == "arm64" or $m.arch == "arm" or $m.arch == "s390x" then
				empty
			else
				f::print_error("Unknown arch: \($m.arch) (context: \(.name))")
			end
		),
		url: "https://get.helm.sh/helm-\($version)-\($m.os)-\($m.arch).tar.gz",
		created_at,
		download_count
	}
	| "\(.variant)|\(.version)|\(.os)|\(.arch)|\(.url)|\(.created_at)#\(.download_count)" | tostring