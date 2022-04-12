# shellcheck shell=bash

haxe.matrix() {
	m.fetch_github_release 'HaxeFoundation/haxe' \
		| jq -rf "$BASALT_PACKAGE_DIR/pkg/src/filters/haxe.jq"
}

haxe.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './haxe.tar.gz' "$url"
	m.ensure tar xaf './haxe.tar.gz'
	m.ensure mv ./*/ './dir'
	mkdir -p './dir/bin'
	m.ensure mv ./dir/haxe* './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}