# shellcheck shell=bash

fstar.table() {
	m.fetch_github_release 'FStarLang/FStar' \
		| m.run_jq 'github-release' \
			--arg global_variant 'FStar' \
			--arg global_regex "^fstar_(?<version>.+)_(?<os>.+)_(?<arch>x86_64)\\."
}

fstar.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './fstar.tar.gz' "$url"
	m.ensure tar xf './fstar.tar.gz'
	m.ensure mv './fstar' './dir'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
