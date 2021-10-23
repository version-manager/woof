# shellcheck shell=bash

ensure.cd() {
	if ! cd "$@"; then
		die "Could not cd"
	fi
}
