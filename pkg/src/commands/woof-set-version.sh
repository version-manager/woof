# shellcheck shell=bash

woof-set-version() {
	local flag_global='no'
	local arg=
	for arg; do case $arg in
	--global)
		flag_global='yes'
		;;
	-*)
		core.print_die "Flag '$arg' not recognized"
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

	helper.determine_tool_version_installed "$tool_name" "$possible_tool_version"
	local tool_version="$REPLY"
	unset -v possible_tool_version

	if [ "$flag_global" = 'yes' ]; then
		util.tool_set_global_version "$tool_name" "$tool_version"

		util.tool_symlink_global_versions "$tool_name" "$tool_version"
	else
		util.tool_set_local_version "$tool_name" "$tool_version"

		util.tool_symlink_local_versions "$tool_name" "$tool_version"
	fi
	util.print_info "Symlinked version '$tool_version'"
}
