# shellcheck shell=bash

vagrant.table() {
	p.run_bash 'hashicorp' 'vagrant'
}

vagrant.install() {
	local url="$1"
	local version="$2"

	p.fetch -o './vagrant.zip' "$url"
	p.mkdir './dir/bin'
	p.unpack './vagrant.zip' -d'./dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
