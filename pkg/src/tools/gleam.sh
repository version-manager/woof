# shellcheck shell=bash

gleam.table() {
	m.fetch_github_release 'gleam-lang/gleam' \
		| m.run_jq 'github-release' \
			--arg global_variant 'Gleam' \
			--arg global_regex "^gleam-(?<version>.+)-(?<os>linux|macos)(?:-(?<arch>.+?))?\\." \
			--arg global_default_arch "x86_64" # FIXME possible bug? (universal?)
}

gleam.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './gleam.tar.gz' "$url"
	mkdir -p './dir/bin'
	m.unpack './gleam.tar.gz' -d'./dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
