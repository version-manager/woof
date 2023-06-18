# shellcheck shell=bash

woof-plugin-enable() {
	local -a plugins=()
	local arg=
	for arg; do case $arg in
	--help)
		util.help_show_usage_and_flags 'plugin enable'
		util.help_show_part '.plugin.enable'
		exit 0
		;;
	-*)
		util.print_help_die '.plugin.enable' "Flag '$arg' not recognized"
		;;
	*)
		plugins+=("$arg")
	esac done; unset -v arg

	helper.plugin_enable "${plugins[@]}"
}
