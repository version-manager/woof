# shellcheck shell=bash

die() {
	local msg="$1"

	printf '%s\n' "Error: $1. Exiting"
	exit 1
}

isMain() {
	if [ "${BASH_SOURCE[0]}" != "${0}" ]; then :; else
		return $?
	fi
}
