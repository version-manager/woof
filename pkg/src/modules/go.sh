# shellcheck shell=bash

go.matrix() {
	m.fetch 'https://go.dev/dl' \
		| perl "$BASALT_PACKAGE_DIR/pkg/src/filters/go.pl"
}

go.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './file.tar.gz' "$url"
	mkdir -p './dir'
	m.ensure tar xf './file.tar.gz' -C './dir' --strip-components=1

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
