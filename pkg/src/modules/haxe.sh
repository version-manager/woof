# shellcheck shell=bash

haxe.table() {
	m.fetch_github_release 'HaxeFoundation/haxe' \
		| m.run_jq 'github-release' \
			--arg global_variant 'Haxe' \
			--arg global_regex "^haxe-.+-(?<os>.+?)\\." \
			--arg global_default_arch "x86_64"
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
