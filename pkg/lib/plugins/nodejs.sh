# shellcheck shell=bash

# reference: https://github.com/nodejs/node
# don't use node on spidermonkey, jsc, chakra, etc.

nodejs.list() {
	local json=
	if ! json="$(util.fetch -o- https://nodejs.org/download/release/index.json)"; then
		die.code 'FAILED_GET_VERSIONS'
	fi

	local -a versions=()
	readarray -t versions < <(jq -r '.[] | .version' <<< "$json" | sort -V)


	ui.select_version 0 "${versions[@]}"
	local selected_version="$REPLY"
	g.stty_deinit

	# printf '%s\n' "Selected: ${versions[$selected_version]}"

	echo sierra
	echo tango
	echo "you chose: ${versions[$selected_version]}"
	# echo victor

}
