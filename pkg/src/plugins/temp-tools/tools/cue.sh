# shellcheck shell=bash

cue.table() {
	p.fetch_github_release 'cue-lang/cue' \
		| p.run_jq 'github-release' \
			--arg global_variant 'Cue' \
			--arg global_regex "^cue_v(?<version>.+?)_(?<os>.+?)_(?<arch>.+?)\\."
}

cue.install() {
	local url="$1"
	local version="$2"

	p.fetch -o './cue.tar.gz' "$url"
	p.mkdir './dir'
	p.unpack './cue.tar.gz' -d'./dir'
	p.mkdir './dir/bin'
	p.ensure mv './dir/cue' './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
