# shellcheck shell=bash

f.is_main() {
	if [ "${BASH_SOURCE[0]}" != "${0}" ]; then :; else
		return $?
	fi
}

f.die() {
	local msg="$1"

	printf '%s\n' "Error: $msg. Exiting" >&2
	exit 1
}

f.print_error() {
	printf '%s\n' "Error: %s" >&2
}
