# shellcheck shell=bash

# hippyvm
# jphp
# taguavm
# peachpie
php.list() {
	local -a versions=()
	mutil.git_tag_to_versions_array 'versions' 'https://github.com/php/php-src' 'refs/tags/php-'
	versions=("${versions[@]/#/v}")

	tty.multiselect 0 "${versions[@]}"
	local selected_version="$REPLY"
	tty.fullscreen_deinit
}
