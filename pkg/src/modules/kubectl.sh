# shellcheck shell=bash

kubectl.matrix() {
	m.run_bash 'kubectl'
}

kubectl.install() {
	local url="$1"
	local version="$2"

	m.fetch -O "$url"
	mkdir -p './dir/bin'
	m.ensure chmod +x './kubectl'
	m.ensure mv './kubectl' './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}