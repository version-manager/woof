# shellcheck shell=bash

haxe.table() {
	p.fetch_github_release 'HaxeFoundation/haxe' \
		| p.run_jq 'github-release' \
			--arg global_variant 'Haxe' \
			--arg global_regex "^haxe-.+-(?<os>.+?)\\." \
			--arg global_default_arch "x86_64"
}

haxe.install() {
	local url="$1"
	local version="$2"

	p.fetch -o './haxe.tar.gz' "$url"
	p.unpack './haxe.tar.gz'
	p.ensure mv ./*/ './dir'
	p.mkdir './dir/bin'
	p.ensure mv ./dir/haxe* './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
