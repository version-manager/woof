# shellcheck shell=bash

util.plugin_get_global_version() {
	local plugin_name="$1"

	var.get_dir 'data-global' 'selection'
	local dir="$REPLY"

	if [ ! -f "$dir/$plugin_name" ]; then
		core.print_die "Failed to find global default for plugin '$plugin_name'"
	fi

	unset -v REPLY; REPLY=
	REPLY=$(<"$dir/$plugin_name")
}

util.plugin_get_local_version() {
	local plugin_name="$1"

	if var.get_tty_dir; then
		local dir="$REPLY/selection"

		if [ ! -f "$dir/$plugin_name" ]; then
			core.print_die "Failed to find local default for plugin '$plugin_name'"
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

util.plugin_symlink_core() {
	local plugin_name="$1"
	local plugin_version="$2"
	local target_bin_dir="$3"

	var.get_dir 'installs' "$plugin_name"
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
