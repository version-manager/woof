# shellcheck shell=bash

nomad.table() {
	p.run_bash 'hashicorp' 'nomad'
}

nomad.install() {
	local url="$1"
	local version="$2"

	p.fetch -o './nomad.zip' "$url"
	p.mkdir './dir/bin'
	p.unpack './nomad.zip' -d'./dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
