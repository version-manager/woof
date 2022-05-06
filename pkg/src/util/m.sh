# shellcheck shell=bash

m.ensure() {
	if "$@"; then :; else
		print.die "Command '$*' failed (code $?)"
	fi
}

m.fetch() {
	print.info 'Fetching' "$url"
	m.ensure curl -fsSL "$@"
}

m.rmln() {
	local target="$1"
	local link="$2"

	m.ensure rm -rf "$link" 
	m.ensure ln -sf "$target" "$link"
}

m.unpack() {
	local cmd="$1"
	local file="$2"

	if ! shift; then
		print.die "Failed to shift"
	fi
	if ! shift; then
		print.die "Failed to shift"
	fi
	if [ "$cmd" = 'tar' ]; then
		print.info 'Unpacking' "$PWD/$file"
		m.ensure tar xf "$@" "$file"
	else
		print.die "m.unpack: Unrecognized argument: $cmd"
	fi
}

m.run_bash() {
	local file="$1"
	
	# Ex. 'm.run_bash "$BASALT_PACKAGE_DIR/pkg/src/filters/hashicorp.sh" "consul"'
	if [[ ${file::1} == '/' ]]; then
		bash "$@"
	# Ex. 'm.run_bash "hashicorp" "consul"'
	elif [[ $file =~ ^[[:alpha:]]+$ ]]; then
		bash "$BASALT_PACKAGE_DIR/pkg/src/filters/$file.sh" "${@:2}"
	else
		bash "$@"
	fi
}

m.run_jq() {
	local file="$1"
	
	# Ex. 'm.run_jq "$BASALT_PACKAGE_DIR/pkg/src/filters/crystal.jq"'
	if [[ ${file::1} == '/' ]]; then
		jq -L "$BASALT_PACKAGE_DIR/pkg/src/filters/util" -rf "$@"
	# Ex. 'm.run_jq "crystal"'
	elif [[ $file =~ ^[[:alpha:]]+$ ]]; then
		jq -L "$BASALT_PACKAGE_DIR/pkg/src/filters/util" -rf "$BASALT_PACKAGE_DIR/pkg/src/filters/$file.jq" "${@:2}"
	else
		jq -L "$BASALT_PACKAGE_DIR/pkg/src/filters/util" "$@"
	fi
}

m.log() {
	printf '%s\n' "$1"
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

m.fetch_github_tags() {
	local prefix="$1"
	
	local {_,refspec}=
	while read -r _ refspec; do
		printf '%s\n' "${refspec#refs/tags/}"
	done < <(git ls-remote --refs --tags "https://github.com/$prefix")
}

m.fetch_github_release() {
	local repo="$1"
	
	local -i has_more_pages=2 i=1
	for ((i=1; has_more_pages==2; ++i)); do
		local url="https://api.github.com/repos/$repo/releases?per_page=100&page=$i"
		
		if m.fetch -H "Authorization: token $GITHUB_TOKEN" "$url" \
			| jq -L "$BASALT_PACKAGE_DIR/pkg/src/filters/util" 'if length == 0 then "" else . end | if . == "" then halt_error(29) else . end'
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

m.toolversions_get_versions() {
	if helper.toolversions_get_versions "$@"; then :; else
		return $?
	fi

}

m.toolversions_get_first_valid_version() {
	if helper.toolversions_get_first_valid_version "$@"; then :; else
		return $?
	fi
}