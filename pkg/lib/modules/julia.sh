# shellcheck shell=bash

julia.list() {
	local json=
	if ! json="$(util.fetch -o- https://julialang-s3.julialang.org/bin/versions.json)"; then
		print.die.code 'FAILED_GET_VERSIONS'
	fi

	local -a versions=()
	readarray -t versions < <(jq -r '. | to_entries[] | [.key, .value] | .[0]' <<< "$json" | sort -V)
	versions=("${versions[@]/#/v}")


	ui.select_version 0 "${versions[@]}"
	local selected_version="$REPLY"
	tty.fullscreen_deinit
}
