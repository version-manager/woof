# shellcheck shell=bash

util.print_fatal_die() {
	core.print_fatal "$@"
	core.print_stacktrace
	exit 1
}

util.print_error_die() {
	core.print_error "$@"
	exit 1
}

util.print_help_die() {
	util.help_show_usage_and_flags "$1"
	util.help_show_part "$1"
	util.print_error_die "${@:2}"
}

util.print_info() {
	if [ "$global_flag_quiet" = 'no' ]; then
		core.print_info "$@"
	fi
}

util.print_hint() {
	printf '%s\n' "  -> $1"
}
