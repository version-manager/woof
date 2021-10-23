# shellcheck shell=bash

crystal.list() {
	local -a versions=()
	util.versions_from_git 'versions' 'https://github.com/crystal-lang/crystal' 'refs/tags/'
	util.array_filter_out 'versions' '*ruby*'
	versions=("${versions[@]/#/v}")

	ui.select_version 0 "${versions[@]}"
	local selected_version="$REPLY"
	tty.fullscreen_deinit
}
