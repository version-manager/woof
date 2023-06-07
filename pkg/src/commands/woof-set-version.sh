# shellcheck shell=bash

woof-set-version() {
	local -a subcmds=()
	local flag_global='no'
	local arg=
	for arg; do case $arg in
	--help)
		util.help_show_usage_and_flags 'set-version'
		util.help_show_part '.set-version'
		exit 0
		;;
	--global)
		flag_global='yes'
		;;
	-*)
		util.print_help_die '.set-version' "Flag '$arg' not recognized"
		;;
	*)
		subcmds+=("$arg")
	esac done; unset -v arg

	helper.determine_tool_pair "${subcmds[0]}"
	declare -g g_tool_pair="$REPLY"
	declare -g g_plugin_name="$REPLY1"
	declare -g g_tool_name="$REPLY2"

	helper.determine_tool_version_installed "$g_tool_pair" "${subcmds[1]}"
	local tool_version="$REPLY"

	if [ "$flag_global" = 'yes' ]; then
		util.tool_set_global_version "$g_tool_pair" "$g_tool_version"
	else
		util.tool_set_local_version "$g_tool_pair" "$g_tool_version"

	fi
}
