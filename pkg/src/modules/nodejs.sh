# shellcheck shell=bash

nodejs.matrix() {
	bash "$BASALT_PACKAGE_DIR/pkg/src/share/fetchers/nodejs.sh"
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
