# shellcheck shell=bash

python.table() {
	local git_url='https://github.com/python/cpython'
	local dl_url='https://www.python.org/ftp/python'

	local version=
	while read -r version; do # /3.8.16/Python-3.8.16.tar.xz
		printf '%s\n' "Python|${version}|linux|x86_64|$dl_url/${version#v}/Python-${version#v}.tgz"
	done < <(p.fetch_git_tags "$git_url")
}

python.install() {
	local url="$1"
	local version="$2"

	p.fetch -o './python.tar.gz' "$url"
	p.unpack './python.tar.gz'
	mv ./Python-*/ './dir'

	cd './dir'
	./configure --prefix="$PWD/.usr" --enable-optimizations
	make -j"$(nproc)"
	make install

	REPLY_DIR='./dir'
	REPLY_BINS=('./.usr/bin')
}
