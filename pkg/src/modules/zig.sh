# shellcheck shell=bash

zig.matrix() {
	m.fetch 'https://ziglang.org/download/index.json' \
		| jq -rf "$BASALT_PACKAGE_DIR/pkg/src/share/fetchers/zig.jq"
}
