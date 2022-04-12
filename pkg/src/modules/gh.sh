# shellcheck shell=bash

gh.matrix() {
	m.fetch_github_release 'cli/cli' \
		| jq -rf "$BASALT_PACKAGE_DIR/pkg/src/filters/gh.jq"
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