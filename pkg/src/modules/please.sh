# shellcheck shell=bash

please.matrix() {
	m.fetch_github_release 'thought-machine/please' \
		| jq -L "$BASALT_PACKAGE_DIR/pkg/src/filters/util" -rf "$BASALT_PACKAGE_DIR/pkg/src/filters/please.jq"
}

please.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './please.tar.xz' "$url"
	mkdir -p './dir'
	m.ensure tar xf './please.tar.xz'
	mv './please' './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}