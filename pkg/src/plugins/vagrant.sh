# shellcheck shell=bash

vagrant.table() {
	m.run_bash 'hashicorp' 'vagrant'
}

vagrant.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './vagrant.zip' "$url"
	mkdir -p './dir/bin'
	m.ensure unzip -qq './vagrant.zip' -d './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}