# shellcheck shell=bash

v.table() {
	m.fetch_github_release 'vlang/v' \
		| m.run_jq 'v'
}

v.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './v.zip' "$url"
	m.ensure unzip -qq './v.zip'
	m.ensure mv './v' './dir'

	REPLY_DIR='./dir'
	REPLY_BINS=('.')
}