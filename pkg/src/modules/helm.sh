# shellcheck shell=bash

helm.table() {
	m.fetch_github_release 'helm/helm' \
		| m.run_jq 'helm'
}

helm.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './helm.tar.gz' "$url"
	m.unpack 'gzip' './helm.tar.gz'

	m.ensure mv ./*/helm .
	m.ensure mkdir -p './dir/bin'
	m.ensure mv './helm' './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
