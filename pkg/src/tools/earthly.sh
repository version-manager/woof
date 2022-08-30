# shellcheck shell=bash

earthly.table() {
	p.fetch_github_release 'earthly/earthly' \
		| p.run_jq 'github-release' \
			--arg global_variant 'Earthly' \
			--arg global_regex "^earthly-(?<os>.+)-(?<arch>.+)"
}

earthly.install() {
	local url="$1"
	local version="$2"

	p.fetch -o './earthly' "$url"
	p.ensure chmod +x './earthly'
	p.mkdir './dir/bin'
	p.ensure mv './earthly' './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
