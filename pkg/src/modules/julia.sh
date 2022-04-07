# shellcheck shell=bash

julia.matrix() {
	m.fetch 'https://julialang-s3.julialang.org/bin/versions.json' \
		| jq -rf "$BASALT_PACKAGE_DIR/pkg/src/share/fetchers/julia.jq"
}
