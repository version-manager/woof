# shellcheck shell=bash

neko.table() {
	p.fetch_github_release 'HaxeFoundation/neko' \
		| p.run_jq 'github-release' \
			--arg global_variant 'Neko' \
			--arg global_regex "^neko-(?<version>.+?)-(?<os>.+?)(?<arch>(?:64)?)\\." \
			--arg global_default_arch "x86"
}

neko.install() {
	local url="$1"
	local version="$2"

	p.fetch -o './neko.tar.gz' "$url"
	p.unpack './neko.tar.gz'
	p.ensure mv ./neko-*/ './dir'

	REPLY_DIR='./dir'
	REPLY_BINS=('.')
}
