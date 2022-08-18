# shellcheck shell=bash

woof-get-version() {
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

	helper.determine_plugin_name "$possible_plugin_name"
	local plugin_name="$REPLY"
	unset -v possible_plugin_name

	if [ "$flag_local" = 'yes' ]; then
		util.plugin_get_local_version "$plugin_name"
	else
		util.plugin_get_global_version "$plugin_name"
	fi
	local version="$REPLY"

	printf '%s\n' "$version"
}
