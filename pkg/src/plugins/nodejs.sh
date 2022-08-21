# shellcheck shell=bash

nodejs.env() {
	std.shell_variable_assignment 'PNPM_HOME' "${XDG_DATA_HOME:-$HOME/.local/share}/pnpm"
	std.shell_variable_export 'PNPM_HOME'
	std.shell_path_prepend '$PNPM_HOME'
}

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
	# m.ensure mv './dir/lib/node_plugins' './dir/lib/node_plugins_old'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
	REPLY_MANS=('./share/man/man1')
}

nodejs.dir() {
	:
}
