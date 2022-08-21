# shellcheck shell=bash

julia.table() {
	m.fetch 'https://julialang-s3.julialang.org/bin/versions.json' \
		| m.run_jq 'julia'
}

julia.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './julia.tar.gz' "$url"
	m.unpack './julia.tar.gz'
	m.ensure mv ./*/ './dir'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
	REPLY_INCLUDES=('./include')
	REPLY_LIBS=('./lib')
	REPLY_MAN=('./share/man/man1')
}
