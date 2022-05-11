# shellcheck shell=bash
source "${0%/*}/util/util.sh"

parse_solidity() {
	local mirror='https://binaries.soliditylang.org'

	for slug in linux-x86_64 macosx-x86_64; do
		
		local url="$mirror/$slug/list.txt"
		local text=
		if ! text=$(curl -fsSL "$url"); then
			f.die "Could not fetch '$url'"
		fi

		while IFS= read -r line; do
			local module_version=${line%%+*}
			module_version=${module_version##*-}

			local version_url="$mirror/$slug/$line"
			if [ "$slug" = 'linux-x86_64' ]; then
				printf '%s\n' "Solidity|$module_version|linux|x86_64|$version_url"
			else
				printf '%s\n' "Solidity|$module_version|darwin|x86_64|$version_url"
			fi
		done <<< "$text"
	done
}

if f.is_main; then
	parse_solidity "$@"
fi
