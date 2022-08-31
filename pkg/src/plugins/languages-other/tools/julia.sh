# shellcheck shell=bash

julia.table() {
	p.fetch 'https://julialang-s3.julialang.org/bin/versions.json' \
		| p.run_jq 'julia'
}

julia.install() {
	local url="$1"
	local version="$2"

	p.fetch -o './julia.tar.gz' "$url"
	p.unpack './julia.tar.gz'
	p.ensure mv ./*/ './dir'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
	REPLY_INCLUDES=('./include')
	REPLY_LIBS=('./lib')
	REPLY_MAN=('./share/man/man1')
}
