# shellcheck shell=bash

woof-exec() {
	local arg=
	for arg; do case $arg in
	*)
		subcmds+=("$arg")
		shift
	esac done; unset -v arg

	local tool_name="${subcmds[0]}"
	if [ -z "$tool_name" ]; then
		util.print_error_die "Passed tool cannot be empty"
	fi

	local tool_version="${subcmds[1]}"
	if [ -z "$tool_version" ]; then
		util.print_error_die "Passed version cannot be empty"
	fi

	local executable="${subcmds[2]}"
	if [ -z "$executable" ]; then
		util.print_error_die "Passed executable cannot be empty"
	fi

	var.get_dir 'installed-tools' "$tool_name"
	local install_dir="$REPLY"

	util.get_plugin_data "$tool_name" "$tool_version" 'bins'
	local -a bin_dirs="${REPLY[@]}"

	for bin_dir in "${bin_dirs[@]}"; do
		for bin_file in "$install_dir/$tool_version/files/$bin_dir"/*; do
			local bin_name="${bin_file##*/}"
			if [[ -x "$bin_file" && "$bin_name" == "$executable" ]]; then
				exec -a "$executable" "$bin_file" "${subcmds[@]:3}"
			fi
		done
	done; unset -v bin_dir
}
