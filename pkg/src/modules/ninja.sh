# shellcheck shell=bash

ninja.matrix() {
	m.fetch_github_release 'ninja-build/ninja' \
		| m.run_jq 'ninja'
}

ninja.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './ninja.zip' "$url"
	mkdir -p './dir/bin'
	m.ensure unzip -qq './ninja.zip' -d './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}