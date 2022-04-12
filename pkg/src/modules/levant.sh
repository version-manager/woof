# shellcheck shell=bash

levant.matrix() {
	bash "$BASALT_PACKAGE_DIR/pkg/src/filters/hashicorp.sh" 'levant'
}

levant.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './levant.zip' "$url"
	mkdir -p './dir/bin'
	m.ensure unzip -qq './levant.zip' -d './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}