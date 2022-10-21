# shellcheck shell=bash

please.table() {
	p.fetch_github_release 'thought-machine/please' \
		| p.run_jq 'github-release' \
			--arg global_variant 'Please' \
			--arg global_regex "^please_(?:(?<type>servers|shim|tools)_)?(?<version>.+?)_(?<os>.+?)_(?<arch>.+?)\\."
}

please.install() {
	local url="$1"
	local version="$2"

	p.fetch -o './please.tar.gz' "$url"
	p.mkdir './dir'
	p.unpack './please.tar.gz'
	mv './please' './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
