# shellcheck shell=bash

# @description For a given module, construct a table of all versions for all
# platforms (kernel and architecture). This eventually calls the "<module>.table"
# function and properly deals with caching
helper.create_version_table() {
	local module_name="$1"

	var.get_module_table_file "$module_name"
	local table_file="$REPLY"

	print.info 'Gathering versions'
	print.debug "Table file: $table_file"

	if [ ! -d "${table_file%/*}" ]; then
		mkdir -p "${table_file%/*}"
	fi
	local use_cache=no
	if [ -f "$table_file" ]; then
		use_cache=yes
	fi

	if [ "$use_cache" = no ]; then
		local table_string=
		if table_string=$(util.run_function "$module_name.table"); then
			if core.err_exists; then
				print.error "$ERR"
				exit "$ERRCODE"
			fi
		else
			print.die "A fatal error occured while running '$module_name.table'"
		fi

		if [ -z "$table_string" ]; then
			print.die "Function '$module_name.table' must output a well-formed table of variable names. Nothing was sent"
		fi

		if ! printf '%s' "$table_string" > "$table_file"; then
			rm -f "$table_file"
			print.die "Could not write to '$table_file'"
		fi

		unset table_string
	fi
}

helper.install_module_version() {
	local flag_interactive=
	if [ "$1" = '--interactive' ]; then
		flag_interactive='yes'
		if ! shift; then
			core.panic 'Failed to shift'
		fi
	fi
	local module_name="$1"
	local module_version="$2"

	var.get_module_workspace_dir "$module_name"
	local workspace_dir="$REPLY" 

	var.get_module_install_dir "$module_name"
	local install_dir="$REPLY"

	# If there is an interactive flag, then we are debugging the installation
	# process. In this case, make the workspace and install directory someplace
	# totally different
	local interactive_dir=
	if [ "$flag_interactive" = 'yes' ]; then
		if ! interactive_dir="$(mktemp -d)/woof-interactive-$RANDOM"; then
			print.die 'Failed to mktemp'
		fi
		workspace_dir="$interactive_dir/workspace_dir"
		install_dir="$interactive_dir/install_dir"
	fi

	if util.is_module_version_installed "$module_name" "$module_version"; then
		print.die "Version '$module_version' is already installed for module '$module_name'"
	fi

	# Preparation actions
	rm -rf "$workspace_dir" "${install_dir:?}/$module_version"
	mkdir -p "$workspace_dir" "$install_dir/$module_version"

	util.uname_system
	local os="$REPLY1"
	local arch="$REPLY2"

	# Determine correct binary for current system
	if util.get_table_row "$module_name" "$module_version" "$os" "$arch"; then :; else
		exit $?
	fi
	local url="$REPLY1"

	# Execute '<module>.install'
	local old_pwd="$PWD"
	if ! cd -- "$workspace_dir"; then
		core.panic 'Failed to cd'
	fi
	print.debug "Working directory changed to: $PWD"

	unset -v REPLY_DIR
	unset -v REPLY_{BINS,INCLUDES,LIBS,MANS} REPLY_{BASH,ZSH,FISH}_COMPLETIONS
	declare -g REPLY_DIR=
	declare -ag REPLY_BINS=() REPLY_INCLUDES=() REPLY_LIBS=() REPLY_MANS=() REPLY_BASH_COMPLETIONS=() \
		REPLY_ZSH_COMPLETIONS=() REPLY_FISH_COMPLETIONS=()
	if util.run_function "$module_name.install" "$url" "${module_version/#v}" "$os" "$arch"; then
		if core.err_exists; then
			rm -rf "$workspace_dir"
			core.panic
		fi
	else
		rm -rf "$workspace_dir"
		print.die "Unexpected error while calling '$module_name.install'"
	fi
	if ! cd -- "$old_pwd"; then
		core.panic 'Failed to cd'
	fi

	if [ -z "$REPLY_DIR" ]; then
		print.die "Variable '\$REPLY_DIR' must be set at the end of <module>.install"
	fi

	# Move extracted contents to 'installs' directory
	if ! mv "$workspace_dir/$REPLY_DIR" "$install_dir/$module_version/files"; then
		rm -rf "$workspace_dir"
		print.die "Could not move extracted contents to '$install_dir/$module_version/files'"
	fi

	# Save information about bin, man, etc. pages later
	local old_ifs="$IFS"; IFS=':'
	if ! printf '%s\n' "bins=${REPLY_BINS[*]}
mans=${REPLY_MANS[*]}" > "$install_dir/$module_version/data.txt"; then
		rm -rf "$workspace_dir" "${install_dir:?}/$module_version"
		print.die "Could not write to '$install_dir/$module_version/data.txt'"
	fi
	IFS="$old_ifs"

	if [ "$flag_interactive" = 'yes' ]; then
		print.info "Dropping into a shell to interactively debug installation process. Exit shell to continue normally"
		if (
			if ! cd -- "$install_dir/$module_version"; then
				print.die 'Failed to cd'
			fi
			bash
		); then :; else
			local exit_code=$?

			rm -rf "$interactive_dir"
			exit $exit_code
		fi

		rm -rf "$interactive_dir"
	fi

	rm -rf "$workspace_dir"
	touch "$install_dir/$module_version/done"

	print.info 'Installed' "$module_version"	
}

# @description Performs any necessary mucking when switching versions
helper.switch_to_version() {
	local module_name="$1"
	local module_version="$2"

	var.get_dir 'global' 'common'
	local global_common_dir="$REPLY"

	var.get_module_install_dir "$module_name"
	local install_dir="$REPLY"

	if [ ! -d "$global_common_dir" ]; then
		mkdir -p "$global_common_dir"
	fi

	# Execute '<module>.switch'
	local old_pwd="$PWD"
	if ! cd -- "$global_common_dir"; then
		core.panic 'Failed to cd'
	fi
	if util.run_function --optional "$module_name.switch" "$install_dir/$module_version/files" "$module_version"; then
		if core.err_exists; then
			core.panic
		fi
	else
		print.die "Unexpected error while calling '$module_name.switch'"
	fi
	if ! cd -- "$old_pwd"; then
		core.panic 'Failed to cd'
	fi
	print.info 'Using' "$module_version"	
}

helper.symlink_after_install() {
	local module_name="$1"
	local module_version="$2"

	var.get_module_install_dir "$module_name"
	local install_dir="$REPLY"

	var.get_dir 'global' 'bin'
	local global_bin_dir="$REPLY"
	
	util.get_module_data "$module_name" "$module_version" 'bins'
	local -a bin_dirs=("${REPLY[@]}")

	util.get_module_data "$module_name" "$module_version" 'mans'
	local -a man_dirs=("${REPLY[@]}") # FIXME

	if [ ! -d "$global_bin_dir" ]; then
		mkdir -p "$global_bin_dir"
	fi

	local bin_dir=
	for bin_dir in "${bin_dirs[@]}"; do
		if [ -d "$install_dir/$module_version/files/$bin_dir" ]; then
			local bin_file
			for bin_file in "$install_dir/$module_version/files/$bin_dir"/*; do
				if [ -d "$bin_file" ]; then
					continue
				fi

				if [ ! -x "$bin_file" ]; then
					print.warn "File '$bin_file' is in a bin directory, but is not marked as executable"
					continue
				fi

				if ! ln -sf "$bin_file" "$global_bin_dir/${bin_file##*/}"; then
					print.warn "Link failed. Skipping"
				fi
			done; unset -v bin_file
		else
			print.warn "Directory '$bin_dir' does not exist for module '$module_name'"
		fi
	done; unset -v bin_dir
}

