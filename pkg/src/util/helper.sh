# shellcheck shell=bash

# @description For a given module, construct a matrix of all versions for all
# platforms (kernel and architecture). This eventually calls the "<module>.matrix"
# function and properly deals with caching
helper.create_version_matrix() {
	local module_name="$1"

	var.get_cached_matrix_file "$module_name"
	local matrix_file="$REPLY"

	print.info 'Constructing version matrix'
	print.debug "Matrix file: $matrix_file"

	if [ ! -d "${matrix_file%/*}" ]; then
		mkdir -p "${matrix_file%/*}"
	fi
	local use_cache=no
	if [ -f "$matrix_file" ]; then
		use_cache=yes
	fi

	if [ "$use_cache" = no ]; then
		local matrix_string=
		if matrix_string=$(util.run_function "$module_name.matrix"); then
			if core.err_exists; then
				print.error "$ERR"
				exit "$ERRCODE"
			fi
		else
			print.die "A fatal error occured while running '$module_name.matrix'"
		fi

		if [ -z "$matrix_string" ]; then
			print.die "Function '$module_name.matrix' must output a well-formed matrix of variable names. Nothing was sent"
		fi

		if ! printf '%s' "$matrix_string" > "$matrix_file"; then
			rm -f "$matrix_file"
			print.die "Could not write to '$matrix_file'"
		fi

		unset matrix_string
	fi
}

helper.install_module_version() {
	local flag_interactive=
	if [ "$1" = '--interactive' ]; then
		flag_interactive='yes'
		if ! shift; then print.die 'Failed to shift'; fi
	fi
	local module_name="$1"
	local version_string="$2"

	local workspace_dir="$WOOF_STATE_HOME/workspace-$module_name"

	var.get_module_install_dir "$module_name"
	local install_dir="$REPLY"

	var.get_module_common_dir "$module_name"
	local common_dir="$REPLY"

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

	if util.is_module_version_installed "$module_name" "$version_string"; then
		print.die "Version '$version_string' is already installed for module '$module_name'"
	fi

	# Preparation actions
	rm -rf "$workspace_dir" "${install_dir:?}/$version_string"
	mkdir -p "$workspace_dir" "$install_dir/$version_string"

	util.uname_system
	local os="$REPLY1"
	local arch="$REPLY2"

	# Determine correct binary for current system
	if util.get_matrix_row "$module_name" "$version_string" "$os" "$arch"; then :; else
		exit $?
	fi
	local url="$REPLY1"

	# Execute '<module>.install'
	local old_pwd="$PWD"
	if ! cd -- "$workspace_dir"; then
		print.die 'Failed to cd'
	fi
	print.debug "Working directory changed to: $PWD"

	unset -v REPLY_DIR
	unset -v REPLY_{BINS,INCLUDES,LIBS,MANS} REPLY_{BASH,ZSH,FISH}_COMPLETIONS
	declare -g REPLY_DIR=
	declare -ag REPLY_BINS=() REPLY_INCLUDES=() REPLY_LIBS=() REPLY_MANS=() REPLY_BASH_COMPLETIONS=() \
		REPLY_ZSH_COMPLETIONS=() REPLY_FISH_COMPLETIONS=()
	if WOOF_MODULE_COMMON_DIR="$common_dir" util.run_function "$module_name.install" "$url" "${version_string/#v}" "$os" "$arch"; then
		if core.err_exists; then
			rm -rf "$workspace_dir"
			print.error "$ERR"
			exit "$ERRCODE"
		fi
	else
		rm -rf "$workspace_dir"
		print.die "Unexpected error while calling '$module_name.install'"
	fi
	if ! cd -- "$old_pwd"; then
		print.die 'Failed to cd'
	fi

	if [ -z "$REPLY_DIR" ]; then
		print.die "Variable '\$REPLY_DIR' must be set at the end of <module>.install"
	fi

	# Move extracted contents to 'installs' directory
	if ! mv "$workspace_dir/$REPLY_DIR" "$install_dir/$version_string/files"; then
		rm -rf "$workspace_dir"
		print.die "Could not move extracted contents to '$install_dir/$version_string/files'"
	fi

	# Save information about bin, man, etc. pages later
	local old_ifs="$IFS"; IFS=':'
	if ! printf '%s\n' "bins=${REPLY_BINS[*]}
mans=${REPLY_MANS[*]}" > "$install_dir/$version_string/data.txt"; then
		rm -rf "$workspace_dir" "${install_dir:?}/$version_string"
		print.die "Could not write to '$install_dir/$version_string/data.txt'"
	fi
	IFS="$old_ifs"

	if [ "$flag_interactive" = 'yes' ]; then
		print.info "Dropping into a shell to interactively debug installation process. Exit shell to continue normally"
		if (
			if ! cd -- "$install_dir/$version_string"; then
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
	touch "$install_dir/$version_string/done"

	print.info 'Installed' "$version_string"

	# Set the current selection to the just-installed version
	util.set_global_selection "$module_name" "$version_string"
}

helper.symlink_after_install() {
	local module_name="$1"
	local version_string="$2"

	var.get_module_install_dir "$module_name"
	local install_dir="$REPLY"

	var.get_dir 'global' 'bin'
	local global_bin_dir="$REPLY"
	
	util.get_module_data "$module_name" "$version_string" 'bins'
	local -a bin_dirs=("${REPLY[@]}")

	util.get_module_data "$module_name" "$version_string" 'mans'
	local -a man_dirs=("${REPLY[@]}") # FIXME

	if [ ! -d "$global_bin_dir" ]; then
		mkdir -p "$global_bin_dir"
	fi

	local bin_dir=
	for bin_dir in "${bin_dirs[@]}"; do
		if [ -d "$install_dir/$version_string/files/$bin_dir" ]; then
			local bin_file
			for bin_file in "$install_dir/$version_string/files/$bin_dir"/*; do
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

