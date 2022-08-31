# shellcheck shell=bash

levant.table() {
	p.run_bash 'hashicorp' 'levant'
}

levant.install() {
	local url="$1"
	local version="$2"

	p.fetch -o './levant.zip' "$url"
	p.mkdir './dir/bin'
	p.unpack './levant.zip' -d'./dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
