# shellcheck shell=bash

nim.table() {
	p.run_bash 'nim'
}

nim.install() {
	local url="$1"
	local version="$2"

	p.fetch -o file.tar.xz "$url"
	p.mkdir 'dir'
	p.unpack file.tar.xz -d'./dir' -s

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
