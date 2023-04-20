# shellcheck shell=bash

woof-exec() {
	local -a subcmds=()
	local arg=
	for arg; do case $arg in
	--help)
		util.help_show_usage_and_flags 'exec'
		util.help_show_part '.exec'
		exit 0
		;;
	-*)
		util.print_help_die '.exec' "Flag '$arg' not recognized"
		;;
	*)
		subcmds+=("$arg")
	esac done; unset -v arg

	local tool_name="${subcmds[0]}"
	if [ -z "$tool_name" ]; then
		util.print_help_die '.exec' "Passed tool cannot be empty"
	fi

	local tool_version="${subcmds[1]}"
	if [ -z "$tool_version" ]; then
		util.print_help_die '.exec' "Passed version cannot be empty"
	fi

	local executable="${subcmds[2]}"
	if [ -z "$executable" ]; then
		util.print_help_die '.exec' "Passed executable cannot be empty"
	fi

	var.get_dir 'tools' "$tool_name"
	local install_dir="$REPLY"

	util.get_plugin_data "$tool_name" "$tool_version" 'bins'
	local -a bin_dirs="${REPLY[@]}"

	for bin_dir in "${bin_dirs[@]}"; do
		for bin_file in "$install_dir/$tool_version/$bin_dir"/*; do
			local bin_name="${bin_file##*/}"
			if [[ -x "$bin_file" && "$bin_name" == "$executable" ]]; then
				exec -a "$executable" "$bin_file" "${subcmds[@]:3}"
			fi
		done
	done; unset -v bin_dir
}
