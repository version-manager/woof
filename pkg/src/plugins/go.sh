# shellcheck shell=bash

go.env() {
	var.get_dir 'data-global' 'common'
	local global_common_dir="$REPLY"
	# TODO gopath
	:
}

go.table() {
	m.fetch 'https://go.dev/dl' \
		| perl "$BASALT_PACKAGE_DIR/pkg/src/filters/go.pl"
}

go.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './file.tar.gz' "$url"
	mkdir -p './dir'
	m.unpack './file.tar.gz' -d'./dir' -s

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
