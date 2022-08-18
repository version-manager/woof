# shellcheck shell=bash

v.table() {
	m.fetch_github_release 'vlang/v' \
		| m.run_jq 'github-release' \
			--arg global_variant 'V' \
			--arg global_regex "^v_(?<os>.+?)(?:_(?<arch>arm64))?\\." \
			--arg global_default_arch 'x86_64'
}

v.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './v.zip' "$url"
	m.ensure unzip -qq './v.zip'
	m.ensure mv './v' './dir'

	REPLY_DIR='./dir'
	REPLY_BINS=('.')
}
