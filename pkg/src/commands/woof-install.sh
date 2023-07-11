# shellcheck shell=bash

woof-install() {
	local -a args=()
	declare -g g_flag_dry_run='no'
	local flag_no_cache='no' flag_force='no'
	local arg=
	for arg; do case $arg in
	--help)
		util.help_show_usage_and_flags 'install'
		util.help_show_part '.install'
		exit 0
		;;
	--no-cache)
		flag_no_cache='yes'
		;;
	--dry-run)
		g_flag_dry_run='yes'
		;;
	--force)
		flag_force='yes'
		;;
	-*)
		util.print_help_die '.install' "Flag '$arg' not recognized"
		;;
	*)
		args+=("$arg")
	esac done; unset -v arg

	helper.determine_tool_pair_active "${args[0]}"
	declare -g g_tool_pair="$REPLY1"
	declare -g g_plugin_name="$REPLY2"
	declare -g g_tool_name="$REPLY3"

	helper.create_version_table "$flag_no_cache"

	helper.determine_tool_version_active --allow-latest "${args[1]}"
	declare -g g_tool_version="$REPLY"

	local flag_interactive='no'
	helper.install_tool_version "$flag_interactive" "$flag_force"

	util.tool_get_global_version --no-error "$g_tool_pair"
	local tool_version_global="$REPLY"
	if [ -z "$tool_version_global" ]; then
		util.tool_set_global_version "$g_tool_pair" "$g_tool_version"
	fi
}
