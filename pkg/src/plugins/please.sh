# shellcheck shell=bash

please.table() {
	m.fetch_github_release 'thought-machine/please' \
		| m.run_jq 'github-release' \
			--arg global_variant 'Please' \
			--arg global_regex "^please_(?:(?<type>servers|shim|tools)_)?(?<version>.+?)_(?<os>.+?)_(?<arch>.+?)\\."
}

please.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './please.tar.gz' "$url"
	mkdir -p './dir'
	m.ensure tar xf './please.tar.gz'
	mv './please' './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
