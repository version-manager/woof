# shellcheck shell=bash

util.print_info() {
	if [ "$global_flag_quiet" == 'no' ]; then
		core.print_info "$@"
	fi
}

util.print_hint() {
	printf '%s\n' "  -> $1"
}
