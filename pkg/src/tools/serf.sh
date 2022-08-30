# shellcheck shell=bash

serf.table() {
	p.run_bash 'hashicorp' 'serf'
}

serf.install() {
	local url="$1"
	local version="$2"

	p.fetch -o './serf.zip' "$url"
	p.mkdir './dir/bin'
	p.unpack './serf.zip' -d'./dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
