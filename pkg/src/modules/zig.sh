# shellcheck shell=bash

zig.matrix() {
	deno run --allow-net "$BASALT_PACKAGE_DIR/pkg/src/share/fetchers/zig.ts"
}
