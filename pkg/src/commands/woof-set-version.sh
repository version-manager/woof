# shellcheck shell=bash

woof-set-version() {
	local flag_local='no'
	local arg=
	for arg; do case $arg in
	--local)
		flag_local='yes'
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

	if [ "$flag_local" = 'yes' ]; then
		util.plugin_set_local_version "$plugin_name" "$plugin_version"

		util.plugin_symlink_local_versions "$plugin_name" "$plugin_version"
	else
		util.plugin_set_global_version "$plugin_name" "$plugin_version"

		util.plugin_symlink_global_versions "$plugin_name" "$plugin_version"
	fi
	core.print_info "Symlinked version '$plugin_version'"
}
