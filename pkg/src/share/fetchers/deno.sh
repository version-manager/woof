# shellcheck shell=bash
source "${0%/*}/util/util.sh"

parse_deno() {
	local nodejs_url='https://nodejs.org/download/release/index.json'

	local json=
	if ! json="$(curl -fsSL "$nodejs_url")"; then
		core.err_set "Could not fetch '$nodejs_url'"
		return
	fi

}


if isMain; then
	parse_deno "$@"
fi
