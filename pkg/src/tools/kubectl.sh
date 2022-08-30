# shellcheck shell=bash

kubectl.table() {
	p.run_bash 'kubectl'
}

kubectl.install() {
	local url="$1"
	local version="$2"

	p.fetch -O "$url"
	p.mkdir './dir/bin'
	p.ensure chmod +x './kubectl'
	p.ensure mv './kubectl' './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
