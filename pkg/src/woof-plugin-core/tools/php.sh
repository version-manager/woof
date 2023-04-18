# shellcheck shell=bash

php.table() {
	local git_url='https://github.com/php/php-src'
	local dl_url='https://www.php.net/distributions'

	local version=
	while read -r version; do
		if [[ $version == php* ]]; then
			printf '%s\n' "PHP|v${version#php-}|linux|x86_64|$dl_url/$version.tar.gz"
		fi

	done < <(p.fetch_git_tags "$git_url")
}

php.install() {
	local url="$1"
	local version="$2"

	p.fetch -o './php.tar.gz' "$url"
	p.unpack './php.tar.gz'
	mv ./php-*/ './dir'

	cd './dir'
	./configure --prefix="$PWD/.usr"
	make -j"$(nproc)"
	make install

	REPLY_DIR='./dir'
	REPLY_BINS=('./.usr/bin')
}
