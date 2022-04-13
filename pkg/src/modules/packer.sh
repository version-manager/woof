# shellcheck shell=bash

packer.matrix() {
	m.run_bash 'hashicorp' 'packer'
}

packer.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './packer.zip' "$url"
	mkdir -p './dir/bin'
	m.ensure unzip -qq './packer.zip' -d './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}