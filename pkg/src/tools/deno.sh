# shellcheck shell=bash

deno.env() {
	std.shell_variable_assignment 'DENO_INSTALL' "${XDG_STATE_HOME:-$HOME/.local/state}/deno"
	std.shell_variable_export 'DENO_INSTALL'
	std.shell_path_prepend '$DENO_INSTALL'
}

deno.table() {
	m.fetch_github_release 'denoland/deno' \
		| m.run_jq 'deno'
}

deno.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './deno.zip' "$url"
	mkdir -p './dir/bin'
	m.unpack './deno.zip' -d'./dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
