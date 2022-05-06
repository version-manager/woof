# shellcheck shell=bash

python.matrix() {
	local prefix='https://www.python.org'

	local version=
	while read -r version; do
		printf '%s\n' "CPython|$version|linux|x86_64|$prefix/ftp/python/${version#v}/Python-${version#v}.tar.xz"
	done < <(m.fetch_github_tags 'python/cpython')
}

python.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './python.tar.xz' "$url"
	m.ensure tar xf './python.tar.xz'
	m.ensure mv ./Python-*/ './dir'
	m.ensure cd -- './dir'

	./configure \
		--prefix="$PWD/prefix" \
		--enable-optimizations 
	make -j"$(nproc)"
	make install

	m.ensure cd '..' # FIXME

	REPLY_DIR='./dir'
	REPLY_BINS=('./prefix/bin')
}