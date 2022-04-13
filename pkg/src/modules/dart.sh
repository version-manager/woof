# shellcheck shell=bash

dart.matrix() {
	m.run_bash 'dart'
}

dart.install() {
	local url="$1"
	local version="$2"

	m.fetch -o file.zip "$url"
	mkdir -p 'dir'
	m.ensure unzip -qq file.zip -d 'dir'

	dir=(./dir/*)

	REPLY_DIR=${dir[0]}
	REPLY_BINS=('./bin')
}
