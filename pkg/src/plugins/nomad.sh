# shellcheck shell=bash

nomad.table() {
	m.run_bash 'hashicorp' 'nomad'
}

nomad.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './nomad.zip' "$url"
	mkdir -p './dir/bin'
	m.ensure unzip -qq './nomad.zip' -d './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}