# shellcheck shell=bash

gleam.table() {
	m.fetch_github_release 'gleam-lang/gleam' \
		| m.run_jq 'gleam'
}

gleam.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './gleam.tar.gz' "$url"
	mkdir -p './dir/bin'
	m.ensure tar xf './gleam.tar.gz' -C './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
