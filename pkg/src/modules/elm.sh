# shellcheck shell=bash

elm.matrix() {
	deno run --allow-net "$BASALT_PACKAGE_DIR/pkg/src/share/fetchers/elm.ts"
}
