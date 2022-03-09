# shellcheck shell=bash

nim.matrix() {
	bash "$BASALT_PACKAGE_DIR/pkg/src/share/fetchers/nim.sh"
}

nim.install() {
	local url="$1"
	local version="$2"

	m.fetch -o file.tar.xz "$url"
	mkdir -p 'dir'
	m.ensure tar xaf file.tar.xz -C 'dir' --strip-components=1

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
