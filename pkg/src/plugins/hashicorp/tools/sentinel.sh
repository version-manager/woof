# shellcheck shell=bash

sentinel.table() {
	p.run_bash 'hashicorp' 'sentinel'
}

sentinel.install() {
	local url="$1"
	local version="$2"

	p.fetch -o './sentinel.zip' "$url"
	p.mkdir './dir/bin'
	p.unpack './sentinel.zip' -d'./dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
