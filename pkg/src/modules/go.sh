# shellcheck shell=bash

go.matrix() {
	deno run --allow-net "$BASALT_PACKAGE_DIR/pkg/src/share/fetchers/go.ts"
}

go.install() {
	local url="$1"
	local version="$2"

	m.fetch -o file.tar.gz "$url"
	mkdir -p 'dir'
	m.ensure tar xaf file.tar.gz -C 'dir' --strip-components=1

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
