# shellcheck shell=bash

v.table() {
	p.fetch_github_release 'vlang/v' \
		| p.run_jq 'github-release' \
			--arg global_variant 'V' \
			--arg global_regex "^v_(?<os>.+?)(?:_(?<arch>arm64))?\\." \
			--arg global_default_arch 'x86_64'
}

v.install() {
	local url="$1"
	local version="$2"

	p.fetch -o './v.zip' "$url"
	p.unpack './v.zip'
	p.ensure mv './v' './dir'

	REPLY_DIR='./dir'
	REPLY_BINS=('.')
}
