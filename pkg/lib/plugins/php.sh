# shellcheck shell=bash

php.list() {
	local -a versions=()
	util.versions_from_git 'versions' 'https://github.com/php/php-src' 'refs/tags/php-'
	versions=("${versions[@]/#/v}")

	ui.select_version 0 "${versions[@]}"
	local selected_version="$REPLY"
	g.stty_deinit
}
