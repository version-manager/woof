# shellcheck shell=bash

woof-plugin-info() {
	local -a args=()
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
		args+=("$arg")
	esac done; unset -v arg

	helper.plugin_info "${args[@]}"
}
