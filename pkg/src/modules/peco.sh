# shellcheck shell=bash

peco.matrix() {
	m.fetch_github_release 'peco/peco' \
		| m.run_jq 'peco'
}

peco.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './peco.tar.gz' "$url"
	m.ensure tar xf './peco.tar.gz'
	m.ensure mv ./peco_*/ './dir'
	mkdir -p './dir/bin'
	m.ensure mv './dir/peco' './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
	REPLY_INCLUDES=('./include')
	REPLY_LIBS=('./lib')
	REPLY_MAN=('./share/man/man1')
}