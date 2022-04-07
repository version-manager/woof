# shellcheck shell=bash

haxe.matrix() {
	m.fetch_github_release 'HaxeFoundation/haxe' \
		| jq -rf "$BASALT_PACKAGE_DIR/pkg/src/share/fetchers/haxe.jq"
}
