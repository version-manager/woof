# shellcheck shell=bash

nodejs.env() {
	var.get_dir 'plugin-data'
	local global_common_dir="$REPLY"

	# older version of pnpm did not follow the XDG Base Specification
	std.shell_variable_assignment 'PNPM_HOME' "$global_common_dir/pnpm_home"
	std.shell_variable_export 'PNPM_HOME'
	std.shell_path_prepend '$PNPM_HOME'
}

nodejs.table() {
	p.run_bash 'nodejs'
}

nodejs.install() {
	local url="$1"
	local version="$2"

	p.fetch -o './file.tar.gz' "$url"
	p.unpack './file.tar.gz'
	p.mkdir 'dir'
	p.ensure mv ./*/* './dir'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
	REPLY_MANS=('./share/man/man1')
}

nodejs.dir() {
	:
}

nodejs.info() {
	local npm_bin=
	npm_bin=$(npm -g bin)

	printf '%s\n' "npm root -g: $npm_bin"
}
