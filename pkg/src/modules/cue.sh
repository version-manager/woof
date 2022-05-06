# shellcheck shell=bash

cue.table() {
	m.fetch_github_release 'cue-lang/cue' \
		| m.run_jq 'cue'
}

cue.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './cue.tar.gz' "$url"
	mkdir -p './dir'
	m.ensure tar xf './cue.tar.gz' -C './dir'
	mkdir -p './dir/bin'
	m.ensure mv './dir/cue' './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
