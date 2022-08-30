# shellcheck shell=bash

python.table() {
	local prefix='https://www.python.org'

	local version=
	while read -r version; do
		printf '%s\n' "CPython|$version|linux|x86_64|$prefix/ftp/python/${version#v}/Python-${version#v}.tar.xz"
	done < <(p.fetch_github_tags 'python/cpython')
}

python.install() {
	local url="$1"
	local version="$2"

	p.fetch -o './python.tar.xz' "$url"
	p.unpack './python.tar.xz'
	p.ensure mv ./Python-*/ './dir'
	p.cd './dir'

	./configure \
		--prefix="$PWD/prefix" \
		--enable-optimizations
	make -j"$(nproc)"
	make install

	p.cd '..'

	REPLY_DIR='./dir'
	REPLY_BINS=('./prefix/bin')
}
