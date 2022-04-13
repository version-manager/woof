# shellcheck shell=bash

solidity.matrix() {
	bash "$BASALT_PACKAGE_DIR/pkg/src/filters/solidity.sh"
}

solidity.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './solidity' "$url"
	m.ensure chmod +x './solidity'
	mkdir -p './dir/bin'
	m.ensure mv './solidity' './dir/bin'

	REPLY_DIR=('./dir')
	REPLY_BINS=('./bin')
}
