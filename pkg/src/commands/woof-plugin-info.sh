# shellcheck shell=bash

woof-plugin-info() {
	local -a subcmds=()
	local arg=
	for arg; do case $arg in
	--help)
		util.help_show_usage_and_flags 'plugin info'
		util.help_show_part '.plugin.info'
		exit 0
		;;
	-*)
		util.print_help_die '.plugin.info' "Flag '$arg' not recognized"
		;;
	*)
		subcmds+=("$arg")
	esac done; unset -v arg

	local plugin="${subcmds[0]}"

	if [ -z "$plugin" ]; then
		util.print_help_die '.plugin.info' "Passed plugin cannot be empty"
	fi

	local plugin_dir="$REPLY/$plugin"

	util.plugin_show_one "$plugin_dir"
}
