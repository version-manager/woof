# shellcheck shell=bash
source "${0%/*}/util/util.sh"

parse_hashicorp() {
	local product="$1"
	local prefix='https://releases.hashicorp.com'

	local url="$prefix/$product"
	local html=
	if ! html=$(curl -fsSL "$url"); then
		core.err_set "Could not fetch '$url'" # TODO: bug
		return
	fi

	local regex=$'^[ \t]*<a[ \t]*href=[\'"]/(.*)[\'"]>'
	local line=
	while IFS= read -r line; do
		if [[ $line =~ $regex ]]; then
			local version_path="${BASH_REMATCH[1]}"

			local url="$prefix/$version_path"
			local version_html=
			if ! version_html=$(curl -fsSL "$url"); then
				core.err_set "Could not fetch '$url'"
				return
			fi

			local version_regex=$'^[ \t]*<a[ \t]*data-product=".+"[ \t]*data-version="(.+)"[ \t]*data-os="(.+)"[ \t]*data-arch="(.+)"[ \t]*href="(.+)"[ \t]*>'
			local line=
			while IFS= read -r line; do
				if [[ $line == *@('.deb'|'.rpm'|'.zst')* ]]; then
					continue
				fi

				if [[ $line =~ $version_regex ]]; then
					local plugin_version="${BASH_REMATCH[1]}"
					local version_os="${BASH_REMATCH[2]}"
					local version_arch="${BASH_REMATCH[3]}"
					local version_uri="${BASH_REMATCH[4]}"

					case $version_os in
						linux|freebsd|darwin|openbsd|netbsd|solaris) : ;;
						windows|web) continue ;;
						archlinux) continue ;; # (in at least vagrant 2.2.6)
						terraform) continue ;; # Bug with name (in at least terraform 0.12.0-alpha4)
						*) printf '%s\n' "Not support os: $line: $version_os" >&2; exit 1 ;;
					esac

					case $version_arch in
						x86_64|amd64)
							version_arch='x86_64' ;;
						arm64|ppc64le|s390x) : ;;
						# boundary: armelv5|armhfv6
						# nomad: arm{5,6,7}|amd64-lxc
						# packer: mips{,64,le}
						arm|arm5|arm6|arm7|amd64-lxc|armelv5|armhfv6|mips|mips64|mipsle) continue ;; # FIXME
						all) continue ;; # .dmg thing in vagrant
						386) version_arch='x86' ;;
						*) printf '%s\n' "Not support arch: $line: $version_arch" >&2; exit 1 ;;
					esac
					printf '%s\n' "${product^}|v$plugin_version|$version_os|$version_arch|$version_uri"
				fi
			done <<< "$version_html"; unset -v line
		fi
	done <<< "$html"; unset -v line
}

if f.is_main; then
	parse_hashicorp "$@"
fi
