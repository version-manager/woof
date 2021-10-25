# shellcheck shell=bash

elixir.list() {
	local -a versions=()
	util.versions_from_git 'versions' 'https://github.com/elixir-lang/elixir' 'refs/tags/v'
	versions=("${versions[@]/#/v}")

	tty.multiselect 0 "${versions[@]}"
	local selected_version="$REPLY"
	tty.fullscreen_deinit
}
