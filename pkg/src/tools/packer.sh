# shellcheck shell=bash

packer.table() {
	p.run_bash 'hashicorp' 'packer'
}

packer.install() {
	local url="$1"
	local version="$2"

	p.fetch -o './packer.zip' "$url"
	p.mkdir './dir/bin'
	p.unpack './packer.zip' -d'./dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
