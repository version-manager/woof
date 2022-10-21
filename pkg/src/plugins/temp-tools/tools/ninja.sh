# shellcheck shell=bash

ninja.table() {
	p.fetch_github_release 'ninja-build/ninja' \
		| p.run_jq 'github-release' \
			--arg global_variant 'Ninja' \
			--arg global_regex "^ninja-(?<os>.+?)\\." \
			--arg global_default_arch 'x86_64'

}

ninja.install() {
	local url="$1"
	local version="$2"

	p.fetch -o './ninja.zip' "$url"
	p.mkdir './dir/bin'
	p.unpack './ninja.zip' -d'./dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
