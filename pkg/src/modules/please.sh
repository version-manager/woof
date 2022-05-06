# shellcheck shell=bash

please.table() {
	m.fetch_github_release 'thought-machine/please' \
		| m.run_jq 'please'
}

please.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './please.tar.xz' "$url"
	mkdir -p './dir'
	m.ensure tar xf './please.tar.xz'
	mv './please' './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}