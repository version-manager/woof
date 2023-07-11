# shellcheck shell=bash

woof-get-version() {
	local -a args=()
	local flag_global='no'
	local arg=
	for arg; do case $arg in
	--help)
		util.help_show_usage_and_flags 'get-version'
		util.help_show_part '.get-version'
		exit 0
		;;
	--global)
		flag_global='yes'
		;;
	-*)
		util.print_help_die '.get-version' "Flag '$arg' not recognized"
		;;
	*)
		args+=("$arg")
	esac done; unset -v arg

	helper.determine_tool_pair_active "${args[0]}"
	declare -g g_tool_pair="$REPLY1"
	declare -g g_plugin_name="$REPLY2"
	declare -g g_tool_name="$REPLY3"

	local tool_version=
	if [ "$flag_global" = 'yes' ]; then
		util.tool_get_global_version --no-error "$g_tool_pair"
		tool_version="$REPLY"

		if [ -z "$tool_version" ]; then
			core.print_warn "No global default was found for plugin '$g_tool_pair'"
			return
		fi
	else
		util.tool_get_local_version --no-error "$g_tool_pair"
		tool_version="$REPLY"

		if [ -z "$tool_version" ]; then
			core.print_warn "No local default was found for plugin '$g_tool_pair'"
			return
		fi
	fi

	printf '%s\n' "$tool_version"
}
