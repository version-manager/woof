# shellcheck shell=bash

go.list() {
	local -a versions=()
	util.versions_from_git 'versions' 'https://github.com/golang/go' 'refs/tags/go'
	versions=("${versions[@]/#/v}")

	ui.select_version 0 "${versions[@]}"
	local selected_version="$REPLY"
	g.stty_deinit
}
