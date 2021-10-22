# shellcheck shell=bash

deno.list() {
	local -a versions=()
	util.versions_from_git 'versions' 'https://github.com/denoland/deno' 'refs/tags/v'
	versions=("${versions[@]/#/v}")

	ui.select_version 0 "${versions[@]}"
	local selected_version="$REPLY"
	g.stty_deinit
}
