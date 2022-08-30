# shellcheck shell=bash

consul.table() {
	p.run_bash 'hashicorp' 'consul'
}

consul.install() {
	local url="$1"
	local version="$2"

	p.fetch -o './consul.zip' "$url"
	p.mkdir './dir/bin'
	p.unpack './consul.zip' -d'./dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
