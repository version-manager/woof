# shellcheck shell=bash

boundary.table() {
	p.run_bash 'hashicorp' 'boundary'
}

boundary.install() {
	local url="$1"
	local version="$2"

	p.fetch -o './boundary.zip' "$url"
	p.mkdir './dir/bin'
	p.unpack './boundary.zip' -d'./dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
