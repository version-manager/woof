# shellcheck shell=bash

peco.table() {
	p.fetch_github_release 'peco/peco' \
		| p.run_jq 'github-release' \
			--arg global_variant 'Peco' \
			--arg global_regex "^peco_(?<os>.+)_(?<arch>.+?)\\."
}

peco.install() {
	local url="$1"
	local version="$2"

	p.fetch -o './peco.tar.gz' "$url"
	p.unpack './peco.tar.gz'
	p.ensure mv ./peco_*/ './dir'
	p.mkdir './dir/bin'
	p.ensure mv './dir/peco' './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
	REPLY_INCLUDES=('./include')
	REPLY_LIBS=('./lib')
	REPLY_MAN=('./share/man/man1')
}
