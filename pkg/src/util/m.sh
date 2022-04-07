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

m.get_github_release() {
	local repo="$1"
	
	local -i has_more_pages=2 i=1
	for ((i=1; has_more_pages==2; ++i)); do
		local url="https://api.github.com/repos/$repo/releases?per_page=100&page=$i"
		
		if m.fetch -H "Authorization: token $GITHUB_TOKEN" "$url" \
			| jq 'if length == 0 then "" else . end | if . == "" then halt_error(29) else . end'
		then :; else
			local exit_code=$?

			if ((exit_code == 0)); then
				continue
			elif ((exit_code == 29)); then # '29' is not taken by curl
				has_more_pages=0
			else
				print.die "Failed to execute curl or jq"
			fi
		fi
	done
}
