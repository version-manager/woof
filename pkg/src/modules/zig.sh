# shellcheck shell=bash

zig.matrix() {
	m.fetch 'https://ziglang.org/download/index.json' \
		| jq -rf "$BASALT_PACKAGE_DIR/pkg/src/filters/zig.jq"
}

zig.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './zig.tar.xz' "$url"
	m.ensure tar xaf './zig.tar.xz'
	m.ensure mv ./*/ './dir'

	mkdir -p './dir/bin'
	m.ensure mv './dir/zig' './dir/bin'


	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}