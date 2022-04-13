# shellcheck shell=bash

earthly.matrix() {
	m.fetch_github_release 'earthly/earthly' \
		| jq -L "$BASALT_PACKAGE_DIR/pkg/src/filters/util" -rf "$BASALT_PACKAGE_DIR/pkg/src/filters/earthly.jq"
}

earthly.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './earthly' "$url"
	m.ensure chmod +x './earthly'
	mkdir -p './dir/bin'
	m.ensure mv './earthly' './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
