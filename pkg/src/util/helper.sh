# shellcheck shell=bash

# @description For a given plugin, construct a table of all versions for all
# platforms (kernel and architecture). This eventually calls the "<plugin>.table"
# function and properly deals with caching
helper.create_version_table() {
	local plugin_name="$1"
	local flag_no_cache="$2"

	var.get_plugin_table_file "$plugin_name"
	local table_file="$REPLY"

	core.print_info 'Gathering versions'
	core.print_debug "Table file: $table_file"

	if [ ! -d "${table_file%/*}" ]; then
		mkdir -p "${table_file%/*}"
	fi

	local should_use_cache='yes'
	if [ -f "$table_file" ]; then
		should_use_cache=yes
	fi
	if [ "$flag_no_cache" = 'yes' ]; then
		should_use_cache=no
	fi

	if [ "$should_use_cache" = 'no' ]; then
		local table_string=
		if table_string=$(util.run_function "$plugin_name.table"); then
			if core.err_exists; then
				core.print_error "$ERR"
				exit "$ERRCODE"
			fi
		else
			core.print_die "Failed to run '$plugin_name.table()'"
		fi

		if [ -z "$table_string" ]; then
			core.print_die "No versions found for $plugin_name ('$plugin_name.table()' printed nothing)"
		fi

		if ! printf '%s' "$table_string" > "$table_file"; then
			rm -f "$table_file"
			core.print_die "Could not write to '$table_file'"
		fi

		unset -v table_string
	fi
}

helper.install_plugin_version() {
	local flag_interactive='no'
	if [ "$1" = '--interactive' ]; then
		flag_interactive='yes'
		if ! shift; then
			core.panic 'Failed to shift'
		fi
	fi
	local plugin_name="$1"
	local plugin_version="$2"

	var.get_plugin_workspace_dir "$plugin_name"
	local workspace_dir="$REPLY"

	var.get_dir 'installed-tools' "$plugin_name"
	local install_dir="$REPLY"

	# If there is an interactive flag, then we are debugging the installation
	# process. In this case, make the workspace and install directory someplace
	# totally different
	local interactive_dir=
	if [ "$flag_interactive" = 'yes' ]; then
		if ! interactive_dir="$(mktemp -d)/woof-interactive-$RANDOM"; then
			core.print_die 'Failed to mktemp'
		fi
		workspace_dir="$interactive_dir/workspace_dir"
		install_dir="$interactive_dir/install_dir"
	fi

	if util.is_plugin_version_installed "$plugin_name" "$plugin_version"; then
		core.print_die "Version '$plugin_version' is already installed for plugin '$plugin_name'"
	fi

	util.uname_system
	local os="$REPLY1"
	local arch="$REPLY2"

	# Determine correct binary for current system
	util.get_table_row "$plugin_name" "$plugin_version" "$os" "$arch"
	local url="$REPLY1"

	# Preparation actions
	rm -rf "$workspace_dir" "${install_dir:?}/$plugin_version"
	mkdir -p "$workspace_dir" "$install_dir/$plugin_version"

	# Execute '<plugin>.install'
	local old_pwd="$PWD"
	if ! cd -- "$workspace_dir"; then
		core.panic 'Failed to cd'
	fi
	core.print_debug "Working directory changed to: $PWD"

	unset -v REPLY_DIR
	unset -v REPLY_{BINS,INCLUDES,LIBS,MANS} REPLY_{BASH,ZSH,FISH}_COMPLETIONS
	declare -g REPLY_DIR=
	declare -ag REPLY_BINS=() REPLY_INCLUDES=() REPLY_LIBS=() REPLY_MANS=() REPLY_BASH_COMPLETIONS=() \
		REPLY_ZSH_COMPLETIONS=() REPLY_FISH_COMPLETIONS=()
	if util.run_function "$plugin_name.install" "$url" "${plugin_version/#v}" "$os" "$arch"; then
		if core.err_exists; then
			rm -rf "$workspace_dir"
			core.panic
		fi
	else
		rm -rf "$workspace_dir"
		core.print_die "Unexpected error while calling '$plugin_name.install'"
	fi
	if ! cd -- "$old_pwd"; then
		core.panic 'Failed to cd'
	fi

	if [ -z "$REPLY_DIR" ]; then
		core.print_die "Variable '\$REPLY_DIR' must be set at the end of <plugin>.install"
	fi

	# Move extracted contents to 'installed-tools' directory
	if ! mv "$workspace_dir/$REPLY_DIR" "$install_dir/$plugin_version/files"; then
		rm -rf "$workspace_dir"
		core.print_die "Could not move extracted contents to '$install_dir/$plugin_version/files'"
	fi

	# Save information about bin, man, etc. pages later
	local old_ifs="$IFS"; IFS=':'
	if ! printf '%s\n' "bins=${REPLY_BINS[*]}
mans=${REPLY_MANS[*]}" > "$install_dir/$plugin_version/data.txt"; then
		rm -rf "$workspace_dir" "${install_dir:?}/$plugin_version"
		core.print_die "Failed to write to '$install_dir/$plugin_version/data.txt'"
	fi
	IFS="$old_ifs"

	if [ "$flag_interactive" = 'yes' ]; then
		core.print_info "Dropping into a shell to interactively debug installation process. Exit shell to continue normally"
		if (
			if ! cd -- "$workspace_dir"; then
				core.print_die 'Failed to cd'
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
		: > "$install_dir/$plugin_version/done"
		core.print_info 'Installed' "$plugin_version"
	else
		core.print_info "Exiting interactive environment. Intermediate temporary directories have been deleteds"
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

		util.plugin_symlink_global_versions "${file##*/}" "$version"
	done
	core.print_info 'Resymlinked'
}

# @description Performs any necessary mucking when switching versions (TODO)
helper.switch_to_version() {
	local plugin_name="$1"
	local plugin_version="$2"

	var.get_dir 'data-global' 'common'
	local global_common_dir="$REPLY"

	var.get_dir 'installed-tools' "$plugin_name"
	local install_dir="$REPLY"

	if [ ! -d "$global_common_dir" ]; then
		mkdir -p "$global_common_dir"
	fi

	# Execute '<plugin>.switch'
	local old_pwd="$PWD"
	if ! cd -- "$global_common_dir"; then
		core.panic 'Failed to cd'
	fi
	if util.run_function --optional "$plugin_name.switch" "$install_dir/$plugin_version/files" "$plugin_version"; then
		if core.err_exists; then
			core.panic
		fi
	else
		core.print_die "Unexpected error while calling '$plugin_name.switch'"
	fi
	if ! cd -- "$old_pwd"; then
		core.panic 'Failed to cd'
	fi
	core.print_info "Using $plugin_version"
}
