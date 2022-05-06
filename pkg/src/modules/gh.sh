# shellcheck shell=bash

gh.table() {
	m.fetch_github_release 'cli/cli' \
		| m.run_jq 'gh'
}

gh.install() {
	local url="$1"
	local version="$2"

	m.fetch -o gh.tar.gz "$url"
	m.ensure tar xf './gh.tar.gz'
	m.ensure mv ./gh_*/ './dir'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
	REPLY_MAN=('./share/man/man1')
}