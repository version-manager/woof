# shellcheck shell=bash

elm.matrix() {
	m.fetch_github_release 'elm/compiler' \
		| jq -rf "$BASALT_PACKAGE_DIR/pkg/src/share/fetchers/elm.jq"
}
