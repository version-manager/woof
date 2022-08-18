# shellcheck shell=bash

helper.toolversions_set_versions() {
	local toolversions_path="$1"

	declare -gA tools=()
	util.toolversions_parse "$toolversions_path" 'tools'

	local plugin_name=
	for plugin_name in "${!tools[@]}"; do
		local -a versions=()
		IFS='|' read -ra versions <<< "${tools[$plugin_name]}"
		for plugin_version in "${versions[@]}"; do
			if [[ $plugin_version == ref:* ]]; then
				core.print_warn "Skipping '$plugin_version' for '$plugin_name' as 'ref:' is not yet supported"
			elif [[ $plugin_version == path:* ]]; then
				core.print_warn "Skipping '$plugin_version' for '$plugin_name' as 'path:' is not yet supported"
			elif [[ $plugin_version == 'system' ]]; then
				core.print_warn "Skipping 'system' for '$plugin_name' as 'system' is not yet supported"
			else
				if util.is_plugin_version_installed "$plugin_name" "$plugin_version"; then
					printf '%s\n' "Switch to to $plugin_name version $plugin_version"
				else
					printf '%s\n' "Cannot switch to $plugin_name version $plugin_version; try to install it first"
				fi
			fi
		done; unset -v plugin_version
	done; unset -v plugin_name
}

