# shellcheck shell=bash

earthly.table() {
	m.fetch_github_release 'earthly/earthly' \
		| m.run_jq 'earthly'
}

earthly.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './earthly' "$url"
	m.ensure chmod +x './earthly'
	mkdir -p './dir/bin'
	m.ensure mv './earthly' './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
