# shellcheck shell=bash

go.list() {
	local -a versions=()
	util.versions_from_git 'versions' 'https://github.com/golang/go' 'refs/tags/go'
	versions=("${versions[@]/#/v}")

	tty.multiselect 0 "${versions[@]}"
	local selected_version="$REPLY"
	tty.fullscreen_deinit
}
