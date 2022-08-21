# shellcheck shell=bash

woof-get-version() {
	local flag_global='no' flag_fullpath='no'
	local arg=
	for arg; do case $arg in
	--global)
		flag_global='yes'
		;;
	--fullpath)
		flag_fullpath='yes'
		;;
	-*)
		util.print_error_die "Flag '$arg' not recognized"
		;;
	*)
		subcmds+=("$arg")
		shift
	esac done; unset -v arg

	local possible_tool_name="${subcmds[0]}"

	helper.determine_tool_name "$possible_tool_name"
	local tool_name="$REPLY"
	unset -v possible_tool_name

	if [ "$flag_global" = 'yes' ]; then
		util.tool_get_global_version "$flag_fullpath" "$tool_name"
	else
		util.tool_get_local_version "$flag_fullpath" "$tool_name"
	fi
	local version="$REPLY"

	printf '%s\n' "$version"
}
