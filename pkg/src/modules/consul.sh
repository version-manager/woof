# shellcheck shell=bash

consul.matrix() {
	bash "$BASALT_PACKAGE_DIR/pkg/src/filters/hashicorp.sh" 'consul'
}

consul.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './consul.zip' "$url"
	mkdir -p './dir/bin'
	m.ensure unzip -qq './consul.zip' -d './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}