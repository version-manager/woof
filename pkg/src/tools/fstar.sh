# shellcheck shell=bash

fstar.table() {
	p.fetch_github_release 'FStarLang/FStar' \
		| p.run_jq 'github-release' \
			--arg global_variant 'FStar' \
			--arg global_regex "^fstar_(?<version>.+)_(?<os>.+)_(?<arch>x86_64)\\."
}

fstar.install() {
	local url="$1"
	local version="$2"

	p.fetch -o './fstar.tar.gz' "$url"
	p.unpack './fstar.tar.gz'
	p.ensure mv './fstar' './dir'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
