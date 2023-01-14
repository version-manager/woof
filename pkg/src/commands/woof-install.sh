# shellcheck shell=bash

woof-install() {
	local -a subcmds=()
	local flag_no_cache='no' flag_force='no'
	local arg=
	for arg; do case $arg in
	--help)
		util.help_show_usage_and_flags 'install'
		util.help_show_cmd_root 'install'
		exit 0
		;;
	--no-cache)
		flag_no_cache='yes'
		;;
	--force)
		flag_force='yes'
		;;
	-*)
		util.print_error_die "Flag '$arg' not recognized"
		;;
	*)
		subcmds+=("$arg")
	esac done; unset -v arg

	helper.determine_tool_name "${subcmds[0]}"
	local tool_name="$REPLY"

	helper.create_version_table "$tool_name" "$flag_no_cache"

	helper.determine_tool_version --allow-latest "$tool_name" "${subcmds[1]}"
	local tool_version="$REPLY"

	local flag_interactive='no'
	helper.install_tool_version "$flag_interactive" "$flag_force" "$tool_name" "$tool_version"

	util.tool_get_global_version --no-error "$tool_name"
	local tool_version_global="$REPLY"
	if [ -z "$tool_version_global" ]; then
		util.tool_set_global_version "$tool_name" "$tool_version"
	fi

	helper.switch_to_version "$tool_name" "$tool_version"
}
