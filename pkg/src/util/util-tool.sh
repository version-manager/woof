# shellcheck shell=bash

util.get_installed_tools() {
	var.get_dir 'tools'
	local tools_dir="$REPLY"

	unset -v REPLY; declare -ga REPLY=()

	if [ ! -d "$tools_dir" ]; then
		return
	fi

	core.shopt_push -s nullglob
	local tool_dir=
	for tool_dir in "$tools_dir"/*/*/; do
		tool_dir=${tool_dir%/}

		plugin_name=${tool_dir%/*}; plugin_name=${plugin_name##*/}
		tool_name=${tool_dir##*/}

		printf '%s\n' "$plugin_name/$tool_name"
		local tool_version=
		for tool_version in "$tool_dir"/*/; do
			tool_version=${tool_version%/}
			tool_version=${tool_version##*/}

			printf '%s\n' "  $tool_version"
		done; unset -v version
		printf '\n'
	done; unset -v tool_dir
	core.shopt_pop
}
