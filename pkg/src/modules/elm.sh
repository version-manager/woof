# shellcheck shell=bash

elm.matrix() {
	m.fetch_github_release 'elm/compiler' \
		| jq -rf "$BASALT_PACKAGE_DIR/pkg/src/filters/elm.jq"
}

elm.install() {
	local url="$1"
	local version="$2"

	m.fetch -o elm.gz "$url"
	m.ensure gzip -d elm.gz
	m.ensure chmod +x './elm'

	mkdir -p './dir/bin'
	m.ensure mv './elm' './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}