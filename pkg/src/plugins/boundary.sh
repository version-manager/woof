# shellcheck shell=bash

boundary.table() {
	m.run_bash 'hashicorp' 'boundary'
}

boundary.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './boundary.zip' "$url"
	mkdir -p './dir/bin'
	m.unpack './boundary.zip' -d'./dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
