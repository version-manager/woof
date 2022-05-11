# shellcheck shell=bash

util.toolversions_get_path() {
	unset -v REPLY; REPLY=

	local toolversions_file='.tool-versions'
	if ! REPLY=$(
		while [ ! -f "$toolversions_file" ] && [ "$PWD" != / ]; do
			if ! cd ..; then
				exit 1
			fi
		done
		if [ "$PWD" = / ]; then
			exit
		fi
		printf '%s' "$PWD/$toolversions_file"
	); then
		core.panic "Could not cd when looking for '$toolversions_file'"
	fi
}

# TODO: check if the line is valid (module that exists, must have a version)
util.toolversions_foreach() {
	unset -v EACH_MODULE_NAME EACH_MODULE_VERSIONS
	if [ -z "$1" ]; then
		return
	fi
	EACH_MODULE_NAME=
	local -ga EACH_MODULE_VERSIONS=()

	local -n __line="$1"
	
	__line=${__line%%#*}
	__line=${__line#"${__line%%[![:space:]]*}"}
	__line=${__line%"${__line##*[![:space:]]}"}

	EACH_MODULE_NAME="${__line%% *}"
	IFS=' ' read -ra EACH_MODULE_VERSIONS <<< "${__line#* }"
}