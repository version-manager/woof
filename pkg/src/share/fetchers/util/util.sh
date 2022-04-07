# shellcheck shell=bash

die() {
	local msg="$1"

	printf '%s\n' "Error: $msg. Exiting"
	exit 1
}

is_main() { # FIXME
	if [ "${BASH_SOURCE[0]}" != "${0}" ]; then :; else
		return $?
	fi
}

