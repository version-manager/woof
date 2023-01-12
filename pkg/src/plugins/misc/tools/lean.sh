# shellcheck shell=bash

lean.table() {
	p.fetch_github_release 'leanprover/lean4' \
		| p.run_jq 'github-release' \
			--arg global_variant 'Lean' \
			--arg global_regex "^lean-(?<version>.+)-(?<os>.+?)(?:_(?<arch>.+?))?\\." \
			--arg global_default_arch 'x86_64'
}

lean.install() {
	local url="$1"
	local version="$2"

	p.fetch -o './lean.zip' "$url"
	p.unpack './lean.zip'
	p.ensure mv ./lean-*/ './dir'
	p.ensure mv './dir/bin' './dir/oldbin'
	p.mkdir './dir/bin'
	p.ensure mv './dir/oldbin'/{lake,lean,leanc,leanmake} './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
