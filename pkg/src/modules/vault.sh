# shellcheck shell=bash

vault.matrix() {
	bash "$BASALT_PACKAGE_DIR/pkg/src/filters/hashicorp.sh" 'vault'
}

vault.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './vault.zip' "$url"
	mkdir -p './dir/bin'
	m.ensure unzip -qq './vault.zip' -d './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}