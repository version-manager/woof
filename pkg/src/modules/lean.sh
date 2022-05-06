# shellcheck shell=bash

lean.table() {
	m.fetch_github_release 'leanprover/lean4' \
		| m.run_jq 'lean'
}

lean.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './lean.zip' "$url"
	m.ensure unzip -qq './lean.zip' 
	m.ensure mv ./lean-*/ './dir'
	m.ensure mv './dir/bin' './dir/oldbin'
	mkdir -p './dir/bin'
	m.ensure mv './dir/oldbin'/{lake,lean,leanc,leanmake} './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}