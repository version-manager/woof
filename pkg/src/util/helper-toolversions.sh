# shellcheck shell=bash

helper.toolversions_get_versions() {
	unset -v REPLY; declare -ag REPLY=()
	local module_name="$1"

	util.toolversions_get_path
	local toolversions_path="$REPLY"
	if [ -z "$toolversions_path" ]; then
		return
	fi

	local line=
	while IFS= read -r line; do
		util.toolversions_foreach 'line'

		if [ "$EACH_MODULE_NAME" = "$module_name" ]; then
			REPLY=("${EACH_VERSIONS[@]}")
		fi
	done < "$toolversions_path"; unset -v line
}

helper.toolversions_get_first_valid_version() {
	unset -v REPLY; REPLY=
	local module_name="$1"
	if ! shift; then
		print.die 'Failed shift'
	fi

	local potential_version=
	for potential_version; do
		if [[ $potential_version == ref:* ]]; then
			print.die "Format 'ref:*' not yet supported in toolversions file"
		elif [[ $potential_version == path:* ]]; then
			print.die "Format 'path:*' not yet supported in toolversions file"
		elif [[ $potential_version == system ]]; then
			print.die "Specifying 'system' not yet supported in toolversions file"
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