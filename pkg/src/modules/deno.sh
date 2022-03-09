# shellcheck shell=bash

deno.matrix() {
	deno run --allow-net "$BASALT_PACKAGE_DIR/pkg/src/share/fetchers/deno.ts"
}

deno.install() {
	local url="$1"
	local version="$2"

	m.fetch -o file.zip "$url"
	mkdir -p 'dir/bin'
	m.ensure unzip -qq file.zip -d 'dir/bin'
	bash

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
