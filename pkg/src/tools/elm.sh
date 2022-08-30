# shellcheck shell=bash

elm.table() {
	p.fetch_github_release 'elm/compiler' \
		| p.run_jq 'github-release' \
			--arg global_variant 'Elm' \
			--arg global_regex "bin(.+?)for-(?<os>.+?)[.-](?<arch>64-bit)?" \
			--arg global_default_arch "x86"
}

elm.install() {
	local url="$1"
	local version="$2"

	p.fetch -o elm.gz "$url"
	p.ensure gzip -d elm.gz
	p.ensure chmod +x './elm'

	p.mkdir './dir/bin'
	p.ensure mv './elm' './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
