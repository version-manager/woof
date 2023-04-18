# shellcheck shell=bash

woof-set-version() {
	local -a subcmds=()
	local flag_global='no'
	local arg=
	for arg; do case $arg in
	--help)
		util.help_show_usage_and_flags 'set-version'
		util.help_show_cmd_root 'set-version'
		exit 0
		;;
	--global)
		flag_global='yes'
		;;
	-*)
		util.print_error_die "Flag '$arg' not recognized"
		;;
	*)
		subcmds+=("$arg")
	esac done; unset -v arg

	local possible_tool_name="${subcmds[0]}"
	local possible_tool_version="${subcmds[1]}"

	helper.determine_tool_name "$possible_tool_name"
	local tool_name="$REPLY"
	unset -v possible_tool_name

	helper.determine_tool_version_installed "$tool_name" "$possible_tool_version"
	local tool_version="$REPLY"
	unset -v possible_tool_version

	if [ "$flag_global" = 'yes' ]; then
		util.tool_set_global_version "$tool_name" "$tool_version"
	else
		util.tool_set_local_version "$tool_name" "$tool_version"

	fi
}
