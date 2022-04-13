# shellcheck shell=bash

gleam.matrix() {
	m.fetch_github_release 'gleam-lang/gleam' \
		| jq -L "$BASALT_PACKAGE_DIR/pkg/src/filters/util" -rf "$BASALT_PACKAGE_DIR/pkg/src/filters/gleam.jq"
}

gleam.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './gleam.tar.gz' "$url"
	mkdir -p './dir/bin'
	m.ensure tar xf './gleam.tar.gz' -C './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
