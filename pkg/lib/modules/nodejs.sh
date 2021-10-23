# shellcheck shell=bash

# reference: https://github.com/nodejs/node
# don't use node on spidermonkey, jsc, chakra, etc.

nodejs.fetch() {
	local json=
	if ! json="$(curl -sSf -o- https://nodejs.org/download/release/index.json)"; then
		print.die "Could not fetch 'https://nodejs.org/download/release/index.json'"
	fi

	jq -r 'to_entries[] | [.key, .value] | .[1].version' <<< "$json" | sort -V
}

nodejs.install() {
	local workspace_dir="$1"
	local dest_dir="$2"
	local version="$3"

	local platform='linux'
	local arch='x64'
	curl -fsSo download.tar.xz "https://nodejs.org/download/release/v$version/node-v$version-$platform-$arch.tar.xz"
	tar xf download.tar.xz

	REPLY_BINS=('./bin')
	REPLY_MANS=('./share/man/man1')
}
