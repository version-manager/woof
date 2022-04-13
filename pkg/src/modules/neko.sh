# shellcheck shell=bash

neko.matrix() {
	m.fetch_github_release 'HaxeFoundation/neko' \
		| jq -L "$BASALT_PACKAGE_DIR/pkg/src/filters/util" -rf "$BASALT_PACKAGE_DIR/pkg/src/filters/neko.jq"
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