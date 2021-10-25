# shellcheck shell=bash

mutil.ensure() {
	if ! "$@"; then
		print.die "Command '$*' failed"
	fi
}

mutil.fetch() {
	if curl -fsS "$@"; then :; else
		return $?
	fi
}

# TODO: implement logging
mutil.log() {
	printf '%s\n' "$1" >/dev/null
}
