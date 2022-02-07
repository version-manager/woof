# shellcheck shell=bash

elixir.list() {
	local -a versions=()
	mutil.git_tag_to_versions_array 'versions' 'https://github.com/elixir-lang/elixir' 'refs/tags/v'
	versions=("${versions[@]/#/v}")

	tty.multiselect 0 "${versions[@]}"
	local selected_version="$REPLY"
	tty.fullscreen_deinit
}
