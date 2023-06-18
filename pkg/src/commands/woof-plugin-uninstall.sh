# shellcheck shell=bash

woof-plugin-uninstall() {
	local -a plugins=()
	local arg=
	for arg; do case $arg in
	--help)
		util.help_show_usage_and_flags 'plugin uninstall'
		util.help_show_part '.plugin.uninstall'
		exit 0
		;;
	-*)
		util.print_help_die '.plugin.uninstall' "Flag '$arg' not recognized"
		;;
	*)
		plugins+=("$arg")
	esac done; unset -v arg

	helper.plugin_uninstall "${plugins[@]}"
}
