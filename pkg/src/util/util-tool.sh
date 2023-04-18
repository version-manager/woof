# shellcheck shell=bash


util.tool_get_global_version() {
	# shellcheck disable=SC1007
	local arg= flag_no_error='no'
	for arg; do case $arg in
	--no-error)
		flag_no_error='yes'
		if ! shift; then
			util.print_fatal_die 'Failed to shift'
			exit 1
		fi
		;;
	esac done; unset -v arg

	local tool_name="$1"

	var.get_dir 'data'
	local dir="$REPLY/selection"

	unset -v REPLY; REPLY=

	if [ -f "$dir/$tool_name" ]; then
		REPLY=$(<"$dir/$tool_name")
		return
	else
		if [ "$flag_no_error" = 'yes' ]; then
			return
		else
			util.print_error_die "A global version of '$tool_name' has not been set"
		fi
	fi
}

util.tool_get_local_version() {
	# shellcheck disable=SC1007
	local arg= flag_no_error='no'
	for arg; do case $arg in
	--no-error)
		flag_no_error='yes'
		if ! shift; then
			util.print_fatal_die 'Failed to shift'
			exit 1
		fi
		;;
	esac done; unset -v arg

	local tool_name="$1"

	var.get_dir 'data'
	local dir="$REPLY/selection"

	if [ ! -f "$dir/$tool_name" ]; then
		if [ "$flag_no_error" = 'yes' ]; then
			return
		else
			util.print_error_die "No default was found for plugin '$tool_name'"
		fi
	fi

	unset -v REPLY; REPLY=
	REPLY=$(<"$dir/$tool_name")
}

util.tool_set_global_version() {
	local tool_name="$1"
	local tool_version="$2"
	util.assert_not_empty 'tool_name'
	util.assert_not_empty 'tool_version'

	var.get_dir 'data'
	local dir="$REPLY/selection"

	util.mkdirp "$dir"

	if ! printf '%s\n' "$tool_version" > "$dir/$tool_name"; then
		util.print_error_die "Failed to write new global version to disk"
	fi

	util.print_info "Set version '$tool_version' as global version"
}


util.tool_set_local_version() {
	local tool_name="$1"
	local tool_version="$2"
	util.assert_not_empty 'tool_name'
	util.assert_not_empty 'tool_version'

	var.get_dir 'data'
	local dir="$REPLY/selection"

	util.mkdirp "$dir"

	if ! printf '%s\n' "$tool_version" > "$dir/$tool_name"; then
		util.print_error_die "Failed to write new tty-specific version to disk"
	fi

	util.print_info "Set version '$tool_version' as tty-specific version"
}

util.tool_list_global_versions() {
	local flag_no_cache="$1"
	local flag_all="$2"
	if ! shift 2; then
		util.print_fatal_die 'Failed to shift'
		exit 1
	fi

	# TODO
	# if (( ${#versions[@]} == 0)); then
	# 	term.style_italic -Pd 'No items'
	# 	return
	# fi

	if [ "$flag_all" = 'yes' ]; then
		var.get_dir 'tools' "$tool_name"
		local install_dir="$REPLY"

		# TODO: show ones that are 'done' and not 'done'
		local tool=
		for tool in "$install_dir"/*/; do
			tool=${tool%/}
			tool=${tool##*/}
			local tool_name="$tool"

			# one shoudl already be created / should not do this in list
			# as it could mean network request TODO
			helper.create_version_table "$tool_name" "$flag_no_cache"

			printf '%s\n' "$tool_name"

			util.uname_system
			local real_os="$REPLY1"
			local real_arch="$REPLY2"

			var.get_plugin_table_file "$tool_name"
			local table_file="$REPLY"

			local variant= version= os= arch= url= comment=
			while IFS='|' read -r variant version os arch url comment; do
				if [ "$real_os" = "$os" ] && [ "$real_arch" = "$arch" ]; then
					printf '%s\n' "  $version"
				fi
			done < "$table_file" | util.sort_versions
			unset -v variant version os arch url comment
			# TODO: auto pager
		done
	else
		local possible_tool_name="$1"

		helper.determine_tool_name "$possible_tool_name"
		local tool_name="$REPLY"
		unset -v possible_tool_name


		# DUPLICATE CODE START ?
		helper.create_version_table "$tool_name" "$flag_no_cache"

		printf '%s\n' "$tool_name"

		util.uname_system
		local real_os="$REPLY1"
		local real_arch="$REPLY2"

		var.get_plugin_table_file "$tool_name"
		local table_file="$REPLY"

		local variant= version= os= arch= url= comment=
		while IFS='|' read -r variant version os arch url comment; do
			if [ "$real_os" = "$os" ] && [ "$real_arch" = "$arch" ]; then
				printf '%s\n' "  $version"
			fi
		done < "$table_file" | util.sort_versions
		unset -v variant version os arch url comment
		# DUPLICATE CODE END
	fi
}

util.tool_list_local_versions() {
	local flag_no_cache="$1"
	local flag_all="$2"
	if ! shift 2; then
		util.print_fatal_die 'Failed to shift'
		exit 1
	fi

	util.toolversions_get_file
	local toolversions_file="$REPLY"

	if [ -z "$toolversions_file" ]; then
		util.print_error_die 'Local project not found'
	fi

	local -A tools=()
	util.toolversions_parse "$toolversions_file" 'tools'

	local tool=
	for tool in "${!tools[@]}"; do
		local -a versions=()
		IFS='|' read -r versions <<< "${tools[$tool]}"

		printf '%s\n' "$tool"
		local version=
		for version in "${versions[@]}"; do
			printf '%s\n' "  $version"
		done
	done
}


