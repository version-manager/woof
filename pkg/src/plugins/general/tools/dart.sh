# shellcheck shell=bash

dart.table() {
	p.run_bash 'dart'
}

dart.install() {
	local url="$1"
	local version="$2"

	p.fetch -o file.zip "$url"
	p.mkdir './dir'
	p.unpack './file.zip' -d'dir'

	dir=(./dir/*)

	REPLY_DIR=${dir[0]}
	REPLY_BINS=('./bin')
}
