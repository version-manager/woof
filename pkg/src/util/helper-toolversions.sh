# shellcheck shell=bash

helper.toolversions_set_versions() {
	local toolversions_path="$1"

	declare -gA tools=()
	util.toolversions_parse "$toolversions_path" 'tools'

	local module_name=
	for module_name in "${!tools[@]}"; do
		local -a versions=()
		IFS='|' read -ra versions <<< "${tools[$module_name]}"
		for module_version in "${versions[@]}"; do
			if [[ $module_version == ref:* ]]; then
				core.print_warn "Skipping '$module_version' for '$module_name' as 'ref:' is not yet supported"
			elif [[ $module_version == path:* ]]; then
				core.print_warn "Skipping '$module_version' for '$module_name' as 'path:' is not yet supported"
			elif [[ $module_version == 'system' ]]; then
				core.print_warn "Skipping 'system' for '$module_name' as 'system' is not yet supported"
			else
				if util.is_module_version_installed "$module_name" "$module_version"; then
					printf '%s\n' "Should switch to $module_name version $module_version"
				else
					printf '%s\n' "Should install and switch to $module_name version $module_version"
				fi
			fi
		done; unset -v module_version
	done; unset -v module_name
}

