# shellcheck shell=bash

sentinel.matrix() {
	bash "$BASALT_PACKAGE_DIR/pkg/src/share/fetchers/hashicorp.sh" 'sentinel'
}

sentinel.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './sentinel.zip' "$url"
	mkdir -p './dir/bin'
	m.ensure unzip -qq './sentinel.zip' -d './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}