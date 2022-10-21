# shellcheck shell=bash

deno.env() {
	std.shell_variable_assignment 'DENO_INSTALL' "${XDG_STATE_HOME:-$HOME/.local/state}/deno"
	std.shell_variable_export 'DENO_INSTALL'
	std.shell_path_prepend '$DENO_INSTALL'
}

deno.table() {
	p.fetch_github_release 'denoland/deno' \
		| p.run_jq 'deno'
}

deno.install() {
	local url="$1"
	local version="$2"

	p.fetch -o './deno.zip' "$url"
	p.mkdir './dir/bin'
	p.unpack './deno.zip' -d'./dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
