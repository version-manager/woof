# shellcheck shell=bash

nim.table() {
	m.run_bash 'nim'
}

nim.install() {
	local url="$1"
	local version="$2"

	m.fetch -o file.tar.xz "$url"
	mkdir -p 'dir'
	m.unpack file.tar.xz -d'./dir' -s

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
