# shellcheck shell=bash

solidity.table() {
	p.run_bash 'solidity'
}

solidity.install() {
	local url="$1"
	local version="$2"

	p.fetch -o './solidity' "$url"
	p.ensure chmod +x './solidity'
	p.mkdir './dir/bin'
	p.ensure mv './solidity' './dir/bin'

	REPLY_DIR=('./dir')
	REPLY_BINS=('./bin')
}
