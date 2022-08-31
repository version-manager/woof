# shellcheck shell=bash

gh.table() {
	p.fetch_github_release 'cli/cli' \
		| p.run_jq 'github-release' \
			--arg global_variant 'gh' \
			--arg global_regex "^gh_(?<version>.+?)_(?<os>.+?)_(?<arch>.+?)\\."
}

gh.install() {
	local url="$1"
	local version="$2"

	p.fetch -o gh.tar.gz "$url"
	p.unpack './gh.tar.gz'
	p.ensure mv ./gh_*/ './dir'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
	REPLY_MAN=('./share/man/man1')
}
