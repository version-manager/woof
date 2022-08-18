# shellcheck shell=bash

deno.table() {
	m.fetch_github_release 'denoland/deno' \
		| m.run_jq 'deno'
}

deno.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './deno.zip' "$url"
	mkdir -p './dir/bin'
	m.ensure unzip -qq './deno.zip' -d './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
