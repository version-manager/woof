# shellcheck shell=bash

util.print_fatal_die() {
	core.print_fatal "$@"
	core.print_stacktrace
	exit 1
}

util.print_error_die() {
	core.print_error "$@"
	if [ -n "${DEV_MODE+x}" ]; then # TODO: standardize this
		core.print_stacktrace
	fi
	exit 1
}

util.print_help_die() {
	util.help_show_usage_and_flags "$1"
	util.help_show_part "$1"
	util.print_error_die "${@:2}"
}

util.print_info() {
	if [ "$g_flag_quiet" = 'no' ]; then
		core.print_info "$@"
	fi
}

util.print_hint() {
	printf '%s\n' "  -> $1"
}
