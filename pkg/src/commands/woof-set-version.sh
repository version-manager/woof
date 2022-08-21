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

	local possible_plugin_name="${subcmds[0]}"
	local possible_plugin_version="${subcmds[1]}"

	helper.determine_plugin_name "$possible_plugin_name"
	local plugin_name="$REPLY"
	unset -v possible_plugin_name

	helper.determine_plugin_version_installed "$plugin_name" "$possible_plugin_version"
	local plugin_version="$REPLY"
	unset -v possible_plugin_version

	if [ "$flag_global" = 'yes' ]; then
		util.tool_set_global_version "$plugin_name" "$plugin_version"

		util.tool_symlink_global_versions "$plugin_name" "$plugin_version"
	else
		util.tool_set_local_version "$plugin_name" "$plugin_version"

		util.tool_symlink_local_versions "$plugin_name" "$plugin_version"
	fi
	util.print_info "Symlinked version '$plugin_version'"
}
