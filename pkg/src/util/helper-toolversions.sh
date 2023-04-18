# shellcheck shell=bash

fallback() { # TODO
	printf '%s\n' "$global_bin/$cmd"
}

helper.toolversions_get_executable_safe() {
	unset -v REPLY; REPLY=

	local cmd="$1"

	util.toolversions_get_file
	local toolversions_file="$REPLY"

	if [ -z "$toolversions_file" ]; then
		fallback
		return
	fi

	declare -gA tools=()
	util.toolversions_parse "$toolversions_file" 'tools'

	local tool_name=
	for tool_name in "${!tools[@]}"; do
		# TODO
		local translated_cmd="$cmd"
		if [[ "$cmd" == @(node|npm|npx) ]]; then
			translated_cmd='nodejs'
		fi

		if [ "$tool_name" = "$translated_cmd" ]; then
			local -a versions=()
			IFS='|' read -ra versions <<< "${tools[$tool_name]}"
			for tool_version in "${versions[@]}"; do
				if [[ $tool_version == ref:* ]]; then
					fallback
				elif [[ $tool_version == path:* ]]; then
					fallback
				elif [[ $tool_version == 'system' ]]; then
					fallback
				else
					if util.is_tool_version_installed "$tool_name" "$tool_version"; then
						local dir="$REPLY"
						printf '%s\n' "$dir/bin/$cmd"
					else
						# TODO: prefix with Woof
						printf '%s\n' "Cannot switch to $tool_name version $tool_version; try to install it first" >&2
					fi
				fi
			done; unset -v tool_version

			return
		fi
	done; unset -v tool_name
}

helper.toolversions_set_versions() {
	local toolversions_path="$1"
	util.assert_not_empty 'toolversions_path'

	declare -gA tools=()
	util.toolversions_parse "$toolversions_path" 'tools'

	local tool_name=
	for tool_name in "${!tools[@]}"; do
		local -a versions=()
		IFS='|' read -ra versions <<< "${tools[$tool_name]}"
		for tool_version in "${versions[@]}"; do
			if [[ $tool_version == ref:* ]]; then
				core.print_warn "Skipping '$tool_version' for '$tool_name' as 'ref:' is not yet supported"
			elif [[ $tool_version == path:* ]]; then
				core.print_warn "Skipping '$tool_version' for '$tool_name' as 'path:' is not yet supported"
			elif [[ $tool_version == 'system' ]]; then
				core.print_warn "Skipping 'system' for '$tool_name' as 'system' is not yet supported"
			else
				if util.is_tool_version_installed "$tool_name" "$tool_version"; then
					util.tool_set_local_version "$tool_name" "$tool_version"
					printf '%s\n' "Switched to $tool_name version $tool_version"
				else
					printf '%s\n' "Cannot switch to $tool_name version $tool_version; try to install it first"
				fi
			fi
		done; unset -v tool_version
	done; unset -v tool_name
}

