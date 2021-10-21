# shellcheck shell=bash

die() {
	if [ -n "$1" ]; then
		error "$1. Exiting"
	else
		error "Exiting"
	fi

	exit 1
}

die.code() {
	err.code "$@"

	exit 1
}

error() {
	if [[ -v NO_COLOR || $TERM = dumb ]]; then
		printf "%s\n" "Error: $1" >&2
	else
		printf "\033[0;31m%s\033[0m\n" "Error: $1" >&2
	fi
}

err.code() {
	# TODO: print plugin name and improve error messages

	case "$1" in
	FAILED_GET_VERSIONS) error "Could not get version list" ;;
	*) die "Enum '$1' not valid for err.code()" ;;
	esac
}

warn() {
	if [[ -v NO_COLOR || $TERM = dumb ]]; then
		printf "%s\n" "Warn: $1" >&2
	else
		printf "\033[1;33m%s\033[0m\n" "Warn: $1" >&2
	fi
}

info() {
	if [[ -v NO_COLOR || $TERM = dumb ]]; then
		printf "%s\n" "Info: $1"
	else
		printf "\033[0;34m%s\033[0m\n" "Info: $1"
	fi
}
