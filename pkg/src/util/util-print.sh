# shellcheck shell=bash

util.print_info() {
	if [ "$global_flag_quiet" == 'no' ]; then
		core.print_info "$@"
	fi
}
