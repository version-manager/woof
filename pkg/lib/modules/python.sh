# shellcheck shell=bash

# reference:
# nuitka: https://github.com/Nuitka/Nuitka
# pypy: https://www.pypy.org
# ironpython2: https://github.com/IronLanguages/ironpython2
python.list() {
	local variant="$1"

	case "$variant" in
		cpython)
			local -a versions=()
			mutil.git_tag_to_versions_array 'versions' 'https://github.com/python/cpython' 'refs/tags/v'
			versions=("${versions[@]/#/v}")
			;;
		nuitka)
			local -a versions=()
			mutil.git_tag_to_versions_array 'versions' 'https://github.com/Nuitka/Nuitka' 'refs/tags/'
			versions=("${versions[@]/#/v}")
			;;
		ironpython2)
			local -a versions=()
			mutil.git_tag_to_versions_array 'versions' 'https://github.com/IronLanguages/ironpython2' 'refs/tags/ipy-'
			versions=("${versions[@]/#/v}")
			;;
		*)
			printf '%s\n' 'variant not specified'
			exit 1
			;;
	esac

	tty.multiselect 0 "${versions[@]}"
	local selected_version="$REPLY"
	tty.fullscreen_deinit
}
