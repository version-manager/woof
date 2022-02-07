# shellcheck shell=bash

crystal.list() {
	local -a versions=()
	mutil.git_tag_to_versions_array 'versions' 'https://github.com/crystal-lang/crystal' 'refs/tags/'
	util.array_filter_out 'versions' '*ruby*'
	versions=("${versions[@]/#/v}")

	tty.multiselect 0 "${versions[@]}"
	local selected_version="$REPLY"
	tty.fullscreen_deinit
}
