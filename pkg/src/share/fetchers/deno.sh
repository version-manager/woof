# shellcheck shell=bash
source "${0%/*}/util/util.sh"

parse_deno() {
	# cat releases.json | jq 'type == "array" and length > 1'
	util.get_github_release 'denoland/deno' \
		| jq '.[] | .name // .tag_name | .'

	# local json=
	# if ! json=$(util.get_github_release 'denoland/deno'); then
	# 	core.err_set "Could not fetch '$'"
	# 	return
	# fi
}

if is_main; then
	parse_deno "$@"
fi
