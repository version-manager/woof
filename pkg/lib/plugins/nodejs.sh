# shellcheck shell=bash

nodejs.list() {
	local json=
	if ! json="$(util.fetch -o- https://nodejs.org/download/release/index.json)"; then
		die.code 'FAILED_GET_VERSIONS'
	fi

	local -a versions=()
	readarray -t versions < <(jq -r '.[] | .version' <<< "$json" | sort -V)

	# ui.select_version 2 "$json"
	# local selected_version="$REPLY"
	ui.select_version 0 one two three four five
	ui.select_version 0 "${versions[@]}"
	local selected_version="$REPLY"
	g.stty_deinit

	printf '%s\n' "Selected: $selected_version"
}
