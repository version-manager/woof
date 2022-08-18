# shellcheck shell=bash

ninja.table() {
	m.fetch_github_release 'ninja-build/ninja' \
		| m.run_jq 'github-release' \
			--arg global_variant 'Ninja' \
			--arg global_regex "^ninja-(?<os>.+?)\\." \
			--arg global_default_arch 'x86_64'

}

ninja.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './ninja.zip' "$url"
	mkdir -p './dir/bin'
	m.ensure unzip -qq './ninja.zip' -d './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
