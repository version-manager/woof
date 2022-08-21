# shellcheck shell=bash

util.plugin_get_global_version() {
	# shellcheck disable=SC1007
	local arg= flag_no_error='no'
	for arg; do case $arg in
		--no-error) flag_no_error='yes'; shift || { core.print_fatal 'Failed to shift'; exit 1; } # FIXME
	esac done; unset -v arg

	local plugin_name="$1"

	var.get_dir 'data-global' 'selection'
	local dir="$REPLY"

	unset -v REPLY; REPLY=

	if [ ! -f "$dir/$plugin_name" ]; then
		if [ "$flag_no_error" = 'yes' ]; then
			return
		else
			core.print_die "A global version of '$plugin_name' has not been set"
		fi
	fi

	REPLY=$(<"$dir/$plugin_name")
}

util.plugin_get_local_version() {
	# shellcheck disable=SC1007
	local arg= flag_no_error='no'
	for arg; do case $arg in
		--no-error) flag_no_error='yes'; shift || { core.print_fatal 'Failed to shift'; exit 1; } # FIXME
	esac done; unset -v arg

	local plugin_name="$1"

	if var.get_tty_dir; then
		local dir="$REPLY/selection"

		if [ ! -f "$dir/$plugin_name" ]; then
			if [ "$flag_no_error" = 'yes' ]; then
				return
			else
				core.print_die "Failed to find local default for plugin '$plugin_name'"
			fi
		fi

		unset -v REPLY; REPLY=
		REPLY=$(<"$dir/$plugin_name")
	else
		core.print_die "Failed because standard input is not a tty"
	fi
}

util.plugin_set_global_version() {
	local plugin_name="$1"
	local plugin_version="$2"

	var.get_dir 'data-global' 'selection'
	local dir="$REPLY"

	if [ -d "$dir" ]; then
		mkdir -p "$dir"
	fi

	if ! printf '%s\n' "$plugin_version" > "$dir/$plugin_name"; then
		core.print_die "Failed to write new global version to disk"
	fi

	core.print_info "Set version '$plugin_version' as global version"
}


util.plugin_set_local_version() {
	local plugin_name="$1"
	local plugin_version="$2"

	if var.get_tty_dir; then
		local dir="$REPLY/selection"

		if [ ! -d "$dir" ]; then
			mkdir -p "$dir"
		fi

		if ! printf '%s\n' "$plugin_version" > "$dir/$plugin_name"; then
			core.print_die "Failed to write new tty-specific version to disk"
		fi

		core.print_info "Set version '$plugin_version' as tty-specific version"
	else
		core.print_die "Failed because standard input is not a tty"
	fi
}

util.plugin_list_global_versions() {
	local flag_no_cache="$1"
	local flag_all="$2"
	if ! shift 2; then
		core.print_fatal 'Failed to shift'
		exit 1
	fi

	# TODO
	# if (( ${#versions[@]} == 0)); then
	# 	term.style_italic -Pd 'No items'
	# 	return
	# fi

	if [ "$flag_all" = 'yes' ]; then
		var.get_dir 'installed-tools' "$plugin_name"
		local install_dir="$REPLY"

		# TODO: show ones that are 'done' and not 'done'
		local tool=
		for tool in "$install_dir"/*/; do
			tool=${tool%/}
			tool=${tool##*/}
			local plugin_name="$tool"

			# one shoudl already be created / should not do this in list
			# as it could mean network request TODO
			helper.create_version_table "$plugin_name" "$flag_no_cache"

			printf '%s\n' "$plugin_name"

			util.uname_system
			local real_os="$REPLY1"
			local real_arch="$REPLY2"

			var.get_plugin_table_file "$plugin_name"
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
		local possible_plugin_name="$1"

		helper.determine_plugin_name "$possible_plugin_name"
		local plugin_name="$REPLY"
		unset -v possible_plugin_name


		# DUPLICATE CODE START ?
		helper.create_version_table "$plugin_name" "$flag_no_cache"

		printf '%s\n' "$plugin_name"

		util.uname_system
		local real_os="$REPLY1"
		local real_arch="$REPLY2"

		var.get_plugin_table_file "$plugin_name"
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

util.plugin_list_local_versions() {
	local flag_no_cache="$1"
	local flag_all="$2"
	if ! shift 2; then
		core.print_fatal 'Failed to shift'
		exit 1
	fi

	util.toolversions_get_path
	local toolversions_file="$REPLY"

	if [ -z "$toolversions_file" ]; then
		core.print_die 'Local project not found'
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

util.plugin_symlink_global_versions() {
	local plugin_name="$1"
	local plugin_version="$2"

	var.get_dir 'data-global' 'bin'
	local target_bin_dir="$REPLY"

	util.plugin_symlink_core "$plugin_name" "$plugin_version" "$target_bin_dir"
}

util.plugin_symlink_local_versions() {
	local plugin_name="$1"
	local plugin_version="$2"

	if var.get_tty_dir; then
		local target_bin_dir="$REPLY/bin"

		util.plugin_symlink_core "$plugin_name" "$plugin_version" "$target_bin_dir"
	else
		core.print_die "Failed because standard input is not a tty"
	fi
}

# TODO: private
util.plugin_symlink_core() {
	local plugin_name="$1"
	local plugin_version="$2"
	local target_bin_dir="$3"

	var.get_dir 'installed-tools' "$plugin_name"
	local install_dir="$REPLY"

	util.get_plugin_data "$plugin_name" "$plugin_version" 'bins'
	local -a bin_dirs=("${REPLY[@]}")

	if [ ! -d "$target_bin_dir" ]; then
		mkdir -p "$target_bin_dir"
	fi

	local bin_dir=
	for bin_dir in "${bin_dirs[@]}"; do
		if [ -d "$install_dir/$plugin_version/files/$bin_dir" ]; then
			local bin_file
			for bin_file in "$install_dir/$plugin_version/files/$bin_dir"/*; do
				if [ -d "$bin_file" ]; then
					continue
				fi

				if [ ! -x "$bin_file" ]; then
					core.print_warn "File '$bin_file' is in a bin directory, but is not marked as executable"
					continue
				fi

				if ! ln -sf "$bin_file" "$target_bin_dir/${bin_file##*/}"; then
					core.print_warn "Symlink failed. Skipping"
				fi
			done; unset -v bin_file
		else
			core.print_warn "Directory '$bin_dir' does not exist for plugin '$plugin_name'"
		fi
	done; unset -v bin_dir
}
