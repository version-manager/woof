# shellcheck shell=bash

nodejs.table() {
	m.run_bash 'nodejs'
}

nodejs.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './file.tar.gz' "$url"
	m.unpack 'gzfip' './file.tar.gz'
	mkdir -p 'dir'
	m.ensure mv ./*/* './dir'

	# TODO
	# Here, we ensure that the correct corresponding npm version is installed
	# when switching versions. 
	# mkdir -p "$WOOF_MODULE_COMMON_DIR/node_modules"
	# m.ensure rm -rf "$WOOF_MODULE_COMMON_DIR/node_modules"/{corepack,npm}
	# m.ensure cp -r "$PWD/dir/lib/node_modules"/{corepack,npm} "$WOOF_MODULE_COMMON_DIR/node_modules"
	# m.rmln "$WOOF_MODULE_COMMON_DIR/node_modules" "$PWD/dir/lib/node_modules" 

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
	REPLY_MANS=('./share/man/man1')
}

nodejs.version_from_dir() {
	# TODO
	:
}