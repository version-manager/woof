# shellcheck shell=bash

woof-install() {
	local -a subcmds=()
	local flag_no_cache='no' flag_force='no'
	local arg=
	for arg; do case $arg in
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
		shift
	esac done; unset -v arg

	local possible_tool_name="${subcmds[0]}"
	local possible_tool_version="${subcmds[1]}"

	helper.determine_tool_name "$possible_tool_name"
	local tool_name="$REPLY"
	unset -v possible_tool_name

	helper.create_version_table "$tool_name" "$flag_no_cache"

	helper.determine_tool_version --allow-latest "$tool_name" "$possible_tool_version"
	local tool_version="$REPLY"
	unset -v possible_tool_version

	helper.install_tool_version 'no' "$flag_force" "$tool_name" "$tool_version"

	util.tool_get_global_version --no-error "$tool_name"
	local tool_version_global="$REPLY"
	if [ -z "$tool_version_global" ]; then
		util.tool_set_global_version "$tool_name" "$tool_version"
	fi

	helper.switch_to_version "$tool_name" "$tool_version"
}
