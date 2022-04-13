# shellcheck shell=bash

neko.matrix() {
	m.fetch_github_release 'HaxeFoundation/neko' \
		| m.run_jq 'neko'
}

neko.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './neko.tar.gz' "$url"
	m.ensure tar xf './neko.tar.gz'
	m.ensure mv ./neko-*/ './dir'

	REPLY_DIR='./dir'
	REPLY_BINS=('.')
}