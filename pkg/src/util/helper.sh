# shellcheck shell=bash

# @description For a given plugin, construct a table of all versions for all
# platforms (kernel and architecture). This eventually calls the "<plugin>.table"
# function and properly deals with caching
helper.create_version_table() {
	local tool_name="$1"
	local flag_no_cache="$2"
	util.assert_not_empty 'tool_name'
	util.assert_not_empty 'flag_no_cache'

	var.get_plugin_table_file "$tool_name"
	local table_file="$REPLY"

	util.print_info 'Gathering versions'
	core.print_debug "Table file: $table_file"

	util.mkdirp "${table_file%/*}"

	local should_use_cache='yes'
	if [ ! -f "$table_file" ]; then
		should_use_cache='no'
	fi
	if [ "$flag_no_cache" = 'yes' ]; then
		should_use_cache='no'
	fi

	if [ "$should_use_cache" = 'no' ]; then
		local table_string=
		if table_string=$(util.run_function "$tool_name.table"); then
			if core.err_exists; then
				util.print_error_die "$ERR"
			fi
		else
			util.print_error_die "Failed to run '$tool_name.table()'"
		fi

		if [ -z "$table_string" ]; then
			util.print_error_die "No versions found for $tool_name ('$tool_name.table()' printed nothing)"
		fi

		if ! printf '%s' "$table_string" > "$table_file"; then
			rm -f "$table_file"
			util.print_error_die "Could not write to '$table_file'"
		fi

		unset -v table_string
	fi
}

helper.install_tool_version() {
	local flag_interactive="$1"
	local flag_force="$2"
	local tool_name="$3"
	local tool_version="$4"
	util.assert_not_empty 'flag_interactive'
	util.assert_not_empty 'flag_force'
	util.assert_not_empty 'tool_name'
	util.assert_not_empty 'tool_version'

	var.get_plugin_workspace_dir "$tool_name"
	local workspace_dir="$REPLY"

	var.get_dir 'installed-tools' "$tool_name"
	local install_dir="$REPLY"

	# If there is an interactive flag, then we are debugging the installation
	# process. In this case, make the workspace and install directory someplace
	# totally different
	local interactive_dir=
	if [ "$flag_interactive" = 'yes' ]; then
		if ! interactive_dir="$(mktemp -d)/woof-interactive-$RANDOM"; then
			util.print_error_die 'Failed to mktemp'
		fi
		workspace_dir="$interactive_dir/workspace_dir"
		install_dir="$interactive_dir/install_dir"
	fi

	if util.is_tool_version_installed "$tool_name" "$tool_version"; then
		if [ "$flag_force" = 'yes' ]; then
			if rm -rf "${install_dir:?}/$tool_version"; then :; else
				util.print_error_die "Failed to remove directory: '${install_dir:?}/$tool_version'"
			fi
		else
			core.print_warn "Version '$tool_version' is already installed for plugin '$tool_name'. Switching to that version"
			# TODO: global only thing
			util.tool_set_global_version "$tool_name" "$tool_version"
			return
		fi
	fi

	util.uname_system
	local os="$REPLY1"
	local arch="$REPLY2"

	# Determine correct binary for current system
	util.get_table_row "$tool_name" "$tool_version" "$os" "$arch"
	local url="$REPLY1"

	# Preparation actions
	rm -rf "$workspace_dir" "${install_dir:?}/$tool_version"
	mkdir -p "$workspace_dir" "$install_dir/$tool_version"

	# Execute '<plugin>.install'
	local old_pwd="$PWD"
	if ! cd -- "$workspace_dir"; then
		util.print_error_die 'Failed to cd'
	fi
	core.print_debug "Working directory changed to: $PWD"

	unset -v REPLY_DIR
	unset -v REPLY_{BINS,INCLUDES,LIBS,MANS} REPLY_{BASH,ZSH,FISH}_COMPLETIONS
	declare -g REPLY_DIR=
	declare -ag REPLY_BINS=() REPLY_INCLUDES=() REPLY_LIBS=() REPLY_MANS=() REPLY_BASH_COMPLETIONS=() \
		REPLY_ZSH_COMPLETIONS=() REPLY_FISH_COMPLETIONS=()
	if util.run_function "$tool_name.install" "$url" "${tool_version/#v}" "$os" "$arch"; then
		if core.err_exists; then
			rm -rf "$workspace_dir"
			util.print_error_die "Failed to successfully execute '$tool_name.install'"
		fi
	else
		rm -rf "$workspace_dir"
		util.print_error_die "Unexpected error while calling '$tool_name.install'"
	fi
	if ! cd -- "$old_pwd"; then
		util.print_error_die 'Failed to cd'
	fi

	if [ -z "$REPLY_DIR" ]; then
		util.print_error_die "Variable '\$REPLY_DIR' must be set at the end of <plugin>.install"
	fi

	# Move extracted contents to 'installed-tools' directory
	if ! mv "$workspace_dir/$REPLY_DIR" "$install_dir/$tool_version/files"; then
		rm -rf "$workspace_dir"
		util.print_error_die "Could not move extracted contents to '$install_dir/$tool_version/files'"
	fi

	# Save information about bin, man, etc. pages later
	local old_ifs="$IFS"; IFS=':'
	if ! printf '%s\n' "bins=${REPLY_BINS[*]}
mans=${REPLY_MANS[*]}" > "$install_dir/$tool_version/data.txt"; then
		rm -rf "$workspace_dir" "${install_dir:?}/$tool_version"
		util.print_error_die "Failed to write to '$install_dir/$tool_version/data.txt'"
	fi
	IFS="$old_ifs"

	if [ "$flag_interactive" = 'yes' ]; then
		util.print_info "Dropping into a shell to interactively debug installation process. Exit shell to continue normally"
		if (
			if ! cd -- "$workspace_dir"; then
				util.print_error_die 'Failed to cd'
			fi
			printf '%s\n' "Download URL: $url"
			bash
		); then :; else
			local exit_code=$?

			rm -rf "$interactive_dir"
			exit $exit_code
		fi

		rm -rf "$interactive_dir"
	fi

	rm -rf "$workspace_dir"
	if [ "$flag_interactive" = 'no' ]; then
		: > "$install_dir/$tool_version/done"
		util.print_info "Installed $tool_version"
	else
		util.print_info "Exiting interactive environment. Intermediate temporary directories have been deleteds"
	fi
}

helper.resymlink_global_all() {
	var.get_dir 'data-global' 'selection'
	local dir="$REPLY"

	local file=
	for file in "$dir"/*; do
		local version=
		if ! version=$(<"$file"); then
			print.fatal "Failed to read from '$file'"
		fi
		if [ -z "$version" ]; then
			core.print_fatal 'Selected version cannot be empty'
			util.print_hint "file: '$file'"
			exit 1
		fi

		util.tool_symlink_global_versions "${file##*/}" "$version"
	done
	util.print_info 'Resymlinked'
}

# @description Performs any necessary mucking when switching versions
helper.switch_to_version() {
	local tool_name="$1"
	local tool_version="$2"
	util.assert_not_empty 'tool_name'
	util.assert_not_empty 'tool_version'

	var.get_dir 'data-global' 'common'
	local global_common_dir="$REPLY"

	var.get_dir 'installed-tools' "$tool_name"
	local install_dir="$REPLY"

	util.mkdirp "$global_common_dir"

	util.print_info "Using $tool_version"

	util.tool_symlink_global_versions "$tool_name" "$tool_version"
}
