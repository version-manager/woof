# shellcheck shell=bash

woof-install() {
	local flag_no_cache='no'
	local arg=
	for arg; do case $arg in
	--no-cache)
		flag_no_cache='yes'
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

	helper.install_plugin_version "$plugin_name" "$plugin_version"
	util.get_global_selection
	local global_selection="$REPLY"
	if [ -z "$global_selection" ]; then
		util.set_global_selection "$plugin_name" "$plugin_version"
	fi

	helper.switch_to_version "$plugin_name" "$plugin_version"
	helper.symlink_after_install "$plugin_name" "$plugin_version"
}
