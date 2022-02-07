# shellcheck shell=bash

go.list() {
	local -a versions=()
	m.git_tag_to_versions_array 'versions' 'https://github.com/golang/go' 'refs/tags/go'
	versions=("${versions[@]/#/v}")

	tty.multiselect 0 "${versions[@]}"
	local selected_version="$REPLY"
	tty.fullscreen_deinit
}
