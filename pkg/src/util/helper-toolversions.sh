# shellcheck shell=bash

# TODO: check if the line is valid (module that exists, must have a version)

helper.toolversions_parse() {
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

helper.toolversions_get_versions() {
	local module_name="$1"

	util.toolversions_get_path
	local toolversions_path="$REPLY"
	if [ -z "$toolversions_path" ]; then
		return
	fi

	unset -v REPLY; declare -ag REPLY=()

	local line=
	while IFS= read -r line; do
		util.toolversions_foreach 'line'

		echo v "$EACH_MODULE_NAME"
		if [ "$EACH_MODULE_NAME" = "$module_name" ]; then
			REPLY=("${EACH_MODULE_VERSIONS[@]}")
		fi
	done < "$toolversions_path"; unset -v line
}

helper.toolversions_get_first_valid_version() {
	unset -v REPLY; REPLY=
	local module_name="$1"
	if ! shift; then
		core.print_die 'Failed shift'
	fi

	local potential_version=
	for potential_version; do
		if [[ $potential_version == ref:* ]]; then
			core.print_die "Format 'ref:*' not yet supported in toolversions file"
		elif [[ $potential_version == path:* ]]; then
			core.print_die "Format 'path:*' not yet supported in toolversions file"
		elif [[ $potential_version == system ]]; then
			core.print_die "Specifying 'system' not yet supported in toolversions file"
		else
			if util.is_module_version_installed "$module_name"; then
				REPLY=$potential_version
				break
			else
				REPLY=
			fi
		fi
	done; unset -v potential_version
}

helper.toolversions_set_versions_in_accordance() {
	util.toolversions_get_path
	local toolversions_path="$REPLY"
	if [ -z "$toolversions_path" ]; then
		return
	fi

	local line=
	while IFS= read -r line; do
		util.toolversions_foreach 'line'

		helper.toolversions_get_first_valid_version "$EACH_MODULE_NAME" "${EACH_MODULE_VERSIONS[@]}"
		local module_version="$REPLY"
		if [ -n "$module_version" ]; then
			printf '%s\n' "Should switch to $EACH_MODULE_NAME version $module_version"
		else
			module_version=${EACH_MODULE_VERSIONS[0]}
			printf '%s\n' "Should install and switch to $EACH_MODULE_NAME version $module_version"
		fi
	done < "$toolversions_path"; unset -v line
	util.toolversions_foreach
}
