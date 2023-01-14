# shellcheck shell=bash

woof-plugin-disable() {
	local -a subcmds=()
	local arg=
	for arg; do case $arg in
	--help)
		util.help_show_usage_and_flags 'plugin disable'
		util.help_show_cmd_plugin 'disable'
		exit 0
		;;
	-*)
		util.print_error_die "Flag '$arg' not recognized"
		;;
	*)
		subcmds+=("$arg")
	esac done; unset -v arg

	term.style_italic -Pd 'Not Implemented'
}
