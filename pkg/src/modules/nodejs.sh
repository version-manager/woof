# shellcheck shell=bash

nodejs.table() {
	m.run_bash 'nodejs'
}

nodejs.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './file.tar.gz' "$url"
	m.unpack 'gzip' './file.tar.gz'
	mkdir -p 'dir'
	m.ensure mv ./*/* './dir'

	# TODO:
	# m.ensure mv './dir/lib/node_modules' './dir/lib/node_modules_old'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
	REPLY_MANS=('./share/man/man1')
}

nodejs.switch() {
	local install_dir="$1"
	local module_version="$2"

	# TODO: npm just replaces the symlink with a directory
	# mkdir -p './node_modules'
	# m.ensure rm -rf './node_modules'/{corepack,npm}
	# m.ensure cp -r "$install_dir/lib/node_modules_old"/{corepack,npm} './node_modules'
	# m.ensure ln -sf "$PWD/node_modules" "$install_dir/lib/node_modules"
}

nodejs.dir() {
	:
}