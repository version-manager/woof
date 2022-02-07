# shellcheck shell=bash

m.ensure() {
	if ! "$@"; then
		print.die "Command '$*' failed"
	fi
}

m.fetch() {
	m.ensure curl -fsSL "$@"
}

# TODO: implement logging
m.log() {
	printf '%s\n' "$1" >/dev/null
}

m.git_tag_to_versions_array() {
	local array_variable_name="$1"
	local url="$2"
	local prefix="$3"

	local -n array_variable="$array_variable_name"
	local prefix_length="${#prefix}"
	while read -r _sha1 refspec; do
		if [ "${refspec:0:$prefix_length}" = "$prefix" ]; then
			array_variable+=("${refspec:$prefix_length}")
		fi
	done < <(git ls-remote --refs --tags "$url")
	unset _sha1 refspec
}
