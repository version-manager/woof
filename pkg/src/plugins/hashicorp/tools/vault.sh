# shellcheck shell=bash

vault.table() {
	p.run_bash 'hashicorp' 'vault'
}

vault.install() {
	local url="$1"
	local version="$2"

	p.fetch -o './vault.zip' "$url"
	p.mkdir './dir/bin'
	p.unpack './vault.zip' -d'./dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
