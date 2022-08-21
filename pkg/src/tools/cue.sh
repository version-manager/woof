# shellcheck shell=bash

cue.table() {
	m.fetch_github_release 'cue-lang/cue' \
		| m.run_jq 'github-release' \
			--arg global_variant 'Cue' \
			--arg global_regex "^cue_v(?<version>.+?)_(?<os>.+?)_(?<arch>.+?)\\."
}

cue.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './cue.tar.gz' "$url"
	mkdir -p './dir'
	m.unpack './cue.tar.gz' -d'./dir'
	mkdir -p './dir/bin'
	m.ensure mv './dir/cue' './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
