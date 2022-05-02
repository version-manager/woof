# shellcheck shell=bash

nodejs.matrix() {
	m.run_bash 'nodejs'
}

nodejs.install() {
	local url="$1"
	local version="$2"

	m.ensure curl -fsSo file.tar.gz "$url"
	mkdir -p 'dir'
	m.ensure tar xaf file.tar.gz -C 'dir' --strip-components=1

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
	REPLY_MANS=('./share/man/man1')
}

nodejs.version_from_dir() {
	# TODO
	:
}