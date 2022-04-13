# shellcheck shell=bash

solidity.matrix() {
	m.run_bash 'solidity'
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
