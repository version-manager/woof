# shellcheck shell=bash

util.tool_get_global_version() {
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

	local tool_pair="$1"

	var.get_dir 'data'
	local dir="$REPLY/selection"

	unset -v REPLY; REPLY=

	if [ -f "$dir/$tool_pair" ]; then
		REPLY=$(<"$dir/$tool_pair")
		return
	else
		if [ "$flag_no_error" = 'yes' ]; then
			return
		else
			util.print_error_die "A global version of '$tool_pair' has not been set"
		fi
	fi
}

util.tool_get_local_version() {
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

	local tool_pair="$1"

	var.get_dir 'data'
	local dir="$REPLY/selection"

	unset -v REPLY; REPLY=

	if [ ! -f "$dir/$tool_pair" ]; then
		if [ "$flag_no_error" = 'yes' ]; then
			return
		else
			util.print_error_die "No default was found for plugin '$tool_pair'"
		fi
	fi

	unset -v REPLY; REPLY=
	REPLY=$(<"$dir/$tool_pair")
}

util.tool_set_global_version() {
	local tool_pair="$1"
	local tool_version="$2"
	util.assert_not_empty 'tool_pair'
	util.assert_not_empty 'tool_version'

	var.get_dir 'data'
	local dir="$REPLY/selection"

	util.mkdirp "$dir/$g_plugin_name"

	if ! printf '%s\n' "$g_tool_version" > "$dir/$g_tool_pair"; then
		util.print_error_die "Failed to write new global version to disk"
	fi

	util.print_info "Set version '$g_tool_version' as global version"
}


util.tool_set_local_version() {
	local tool_pair="$1"
	local tool_version="$2"
	util.assert_not_empty 'tool_pair'
	util.assert_not_empty 'tool_version'

	var.get_dir 'data'
	local dir="$REPLY/selection"

	util.mkdirp "$dir"

	if ! printf '%s\n' "$g_tool_version" > "$dir/$tool_pair"; then
		util.print_error_die "Failed to write new tty-specific version to disk"
	fi

	util.print_info "Set version '$g_tool_version' as tty-specific version"
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
		var.get_dir 'tools' "$tool_pair"
		local install_dir="$REPLY"

		# TODO: show ones that are 'done' and not 'done'
		local tool=
		for tool in "$install_dir"/*/; do
			tool=${tool%/}
			tool=${tool##*/}
			local tool_pair="$tool"

			# one shoudl already be created / should not do this in list
			# as it could mean network request TODO
			helper.create_version_table "$flag_no_cache"

			printf '%s\n' "$tool_pair"

			util.uname_system
			local real_os="$REPLY1"
			local real_arch="$REPLY2"

			var.get_plugin_table_file "$tool_pair"
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
		var.get_dir 'tools'
		local tools_dir="$REPLY"

		if ((${#tools_dir[@]} == 0)); then
			term.style_italic -Pd 'No items'
			return
		fi

		util.get_installed_tools
		for tool_dir in "${REPLY[@]}"; do
			printf '%s\n' "dir: $tool_dir"
		done; unset -v tool_dir

		# helper.determine_tool_pair "$1"
		# declare -g g_tool_pair="$REPLY"
		# declare -g g_plugin_name="$REPLY1"
		# declare -g g_tool_name="$REPLY2"

		# # TODO
		# # DUPLICATE CODE START ?
		# helper.create_version_table "$flag_no_cache"

		# printf '%s\n' "$g_tool_pair"

		# util.uname_system
		# local real_os="$REPLY1"
		# local real_arch="$REPLY2"

		# var.get_plugin_table_file "$g_tool_pair"
		# local table_file="$REPLY"

		# local variant= version= os= arch= url= comment=
		# while IFS='|' read -r variant version os arch url comment; do
		# 	if [ "$real_os" = "$os" ] && [ "$real_arch" = "$arch" ]; then
		# 		printf '%s\n' "  $version"
		# 	fi
		# done < "$table_file" | util.sort_versions
		# unset -v variant version os arch url comment
		# # DUPLICATE CODE END
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

util.get_installed_tools() {
	var.get_dir 'tools'
	local tools_dir="$REPLY"

	unset -v REPLY; declare -ga REPLY=()

	if [ ! -d "$tools_dir" ]; then
		return
	fi

	core.shopt_push -s nullglob
	local tool_dir=
	for tool_dir in "$tools_dir"/*/*/; do
		tool_dir=${tool_dir%/}

		plugin_name=${tool_dir%/*}; plugin_name=${plugin_name##*/}
		tool_name=${tool_dir##*/}

		printf '%s\n' "$plugin_name/$tool_name"
		local tool_version=
		for tool_version in "$tool_dir"/*/; do
			tool_version=${tool_version%/}
			tool_version=${tool_version##*/}

			printf '%s\n' "  $tool_version"
		done; unset -v version
		printf '\n'
	done; unset -v tool_dir
	core.shopt_pop
}
