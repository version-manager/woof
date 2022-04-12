# shellcheck shell=bash

deno.matrix() {
	m.fetch_github_release 'denoland/deno' \
		| jq -L "$BASALT_PACKAGE_DIR/pkg/src/filters/util" -rf "$BASALT_PACKAGE_DIR/pkg/src/filters/deno.jq"
}

deno.install() {
	local url="$1"
	local version="$2"

	m.fetch -o file.zip "$url"
	mkdir -p './dir/bin'
	m.ensure unzip -qq file.zip -d './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
