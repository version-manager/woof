# shellcheck shell=bash

woof-plugin-list() {
	local -a args=()
	local arg=
	for arg; do case $arg in
	--help)
		util.help_show_usage_and_flags 'plugin list'
		util.help_show_part '.plugin.list'
		exit 0
		;;
	-*)
		util.print_help_die '.plugin.list' "Flag '$arg' not recognized"
		;;
	*)
		args+=("$arg")
		;;
	esac done; unset -v arg

	helper.plugin_list
}
