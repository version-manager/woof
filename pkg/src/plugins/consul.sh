# shellcheck shell=bash

consul.table() {
	m.run_bash 'hashicorp' 'consul'
}

consul.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './consul.zip' "$url"
	mkdir -p './dir/bin'
	m.unpack './consul.zip' -d'./dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
