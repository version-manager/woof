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
		core.print_die "Flag '$arg' not recognized"
		;;
	*)
		subcmds+=("$arg")
		shift
	esac done; unset -v arg

	local possible_plugin_name="${subcmds[0]}"

	helper.determine_plugin_name "$possible_plugin_name"
	local plugin_name="$REPLY"
	unset -v possible_plugin_name

	if [ "$flag_global" = 'yes' ]; then
		util.plugin_get_global_version "$flag_fullpath" "$plugin_name"
	else
		util.plugin_get_local_version "$flag_fullpath" "$plugin_name"
	fi
	local version="$REPLY"

	printf '%s\n' "$version"
}
