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

util.toolversions_parse() {
	local toolversions_path="$1"
	local -n __toolversions_variable="$2"

	local line=
	while IFS= read -r line; do
		line=${line%%#*}
		line=${line#"${line%%[![:space:]]*}"}
		line=${line%"${line##*[![:space:]]}"}

		if [ -n "$line" ]; then
			local module_name="${line%% *}"
			module_name=${module_name%%$'\t'*}

			local module_versions_str="${line#* }"
			module_versions_str=${module_versions_str#*$'\t'}
			# shellcheck disable=SC2206
			module_versions=($module_versions_str)

			local old_ifs="$IFS"
			IFS='|'
			__toolversions_variable[$module_name]="${module_versions[*]}"
			IFS="$old_ifs"; unset -v old_ifs
		fi

	done < "$toolversions_path"; unset -v line
}
