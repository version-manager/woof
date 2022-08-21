# shellcheck shell=bash

levant.table() {
	m.run_bash 'hashicorp' 'levant'
}

levant.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './levant.zip' "$url"
	mkdir -p './dir/bin'
	m.unpack './levant.zip' -d'./dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
