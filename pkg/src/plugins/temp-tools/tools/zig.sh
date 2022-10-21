# shellcheck shell=bash

zig.table() {
	p.fetch 'https://ziglang.org/download/index.json' \
		| p.run_jq 'zig'
}

zig.install() {
	local url="$1"
	local version="$2"

	p.fetch -o './zig.tar.xz' "$url"
	p.unpack './zig.tar.xz'
	p.ensure mv ./*/ './dir'

	p.mkdir './dir/bin'
	p.ensure mv './dir/zig' './dir/bin'


	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
