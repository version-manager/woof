# shellcheck shell=bash

bash.table() {
	local git_url='https://git.savannah.gnu.org/git/bash'
	local ftp_url='https://ftp.gnu.org/gnu/bash'

	local version=
	while read -r version; do
		printf '%s\n' "Bash|v${version#bash-}|linux|x86_64|$ftp_url/$version.tar.gz"
	done < <(p.fetch_git_tags "$git_url")
}

bash.install() {
	local url="$1"
	local version="$2"

	p.fetch -o './bash.tar.gz' "$url"
	p.unpack './bash.tar.gz'
	mv ./bash-*/ './dir'

	cd './dir'
	./configure --prefix="$PWD/.usr"
	make -j"$(nproc)"
	make install

	REPLY_DIR='./dir'
	REPLY_BINS=('./.usr/bin')
}
