# shellcheck shell=bash

woof-plugin-enable() {
	local -a subcmds=()
	local arg=
	for arg; do case $arg in
	--help)
		util.help_show_usage_and_flags 'plugin enable'
		util.help_show_cmd_plugin 'enable'
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
