# shellcheck shell=bash

woof-get-version() {
	local -a subcmds=()
	local flag_global='no'
	local arg=
	for arg; do case $arg in
	--help)
		util.help_show_usage_and_flags 'get-version'
		util.help_show_cmd_root 'get-version'
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

	helper.determine_tool_name "$possible_tool_name"
	local tool_name="$REPLY"
	unset -v possible_tool_name

	if [ "$flag_global" = 'yes' ]; then
		util.tool_get_global_version --no-error "$tool_name"
		local tool_version="$REPLY"

		if [ -z "$tool_version" ]; then
			core.print_warn "No global default was found for plugin '$tool_name'"
			return
		fi
	else
		util.tool_get_local_version --no-error "$tool_name"
		local tool_version="$REPLY"

		if [ -z "$tool_version" ]; then
			core.print_warn "No local default was found for plugin '$tool_name'"
			return
		fi
	fi

	printf '%s\n' "$tool_version"
}
