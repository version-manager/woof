# shellcheck shell=bash

woof-install() {
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

	helper.create_version_table "$plugin_name" "$flag_no_cache"

	helper.determine_plugin_version --allow-latest "$plugin_name" "$possible_plugin_version"
	local plugin_version="$REPLY"
	unset -v possible_plugin_version

	helper.install_plugin_version 'no' "$flag_force" "$plugin_name" "$plugin_version"

	util.plugin_get_global_version --no-error "$plugin_name"
	local global_selection="$REPLY"
	if [ -z "$global_selection" ]; then
		util.plugin_set_global_version "$plugin_name" "$plugin_version"
	fi

	helper.switch_to_version "$plugin_name" "$plugin_version"
}
