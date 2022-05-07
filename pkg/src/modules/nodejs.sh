# shellcheck shell=bash

nodejs.table() {
	m.run_bash 'nodejs'
}

nodejs.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './file.tar.gz' "$url"
	m.unpack 'gzip' './file.tar.gz'
	mkdir -p 'dir'
	m.ensure mv ./*/* './dir'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
	REPLY_MANS=('./share/man/man1')
}

nodejs.version_from_dir() {
	# TODO
	:
}