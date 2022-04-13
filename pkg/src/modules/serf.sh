# shellcheck shell=bash

serf.matrix() {
	m.run_bash 'hashicorp' 'serf'
}

serf.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './serf.zip' "$url"
	mkdir -p './dir/bin'
	m.ensure unzip -qq './serf.zip' -d './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}