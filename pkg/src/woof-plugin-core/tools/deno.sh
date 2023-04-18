# shellcheck shell=bash

deno.env() {
	var.get_dir 'plugins-data'
	local global_common_dir="$REPLY"

	utility.shell_variable_assignment 'DENO_INSTALL_ROOT' "$global_common_dir/deno_install"
	utility.shell_variable_export 'c'
	utility.shell_path_prepend '$DENO_INSTALL_ROOT/bin'
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
