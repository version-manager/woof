# shellcheck shell=bash

print.die() {
	print.error "$@"

	exit 1
}

print.fatal() {
	if [[ -v NO_COLOR || $TERM = dumb ]]; then
		printf "%s\n" "Fatal: $1" >&2
	else
		printf "\033[0;31m%s\033[0m %s\n" 'Fatal:' "$1" >&2
	fi

	exit 1
}

print.error() {
	if [[ -v NO_COLOR || $TERM = dumb ]]; then
		printf "%s\n" "Error: $1" >&2
	else
		printf "\033[0;31m%s\033[0m %s\n" 'Error:' "$1" >&2
	fi
}

print.warn() {
	if [[ -v NO_COLOR || $TERM = dumb ]]; then
		printf "%s\n" "Warn: $1" >&2
	else
		printf "\033[1;33m%s\033[0m %s\n" 'Warn:' "$1" >&2
	fi
}

print.info() {
	if [[ -v NO_COLOR || $TERM = dumb ]]; then
		printf "%s\n" "Info: $1"
	else
		if [ -n "$2" ]; then
			printf "\033[0;34m%10s\033[0m: %s\n" "$1" "$2"
		else
			printf "\033[0;34m%10s\033[0m: %s\n" 'Info' "$1"
		fi
	fi
}

print.hint() {
	printf '%s\n' "  -> $1"
}

print.debug() {
	if [[ -v DEBUG ]]; then
		printf '%s\n' "Debug: $1"
	fi
}
