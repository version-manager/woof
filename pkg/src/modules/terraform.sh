# shellcheck shell=bash

terraform.matrix() {
	m.run_bash 'hashicorp' 'terraform'
}

terraform.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './terraform.zip' "$url"
	mkdir -p './dir/bin'
	m.ensure unzip -qq './terraform.zip' -d './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}