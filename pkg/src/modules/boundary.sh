# shellcheck shell=bash

boundary.matrix() {
	deno run --allow-net --allow-env --allow-read "$BASALT_PACKAGE_DIR/pkg/src/share/boundary.ts"
}
