# shellcheck shell=bash

util.plugin_get_global_version() {
	local plugin_name="$1"

	var.get_dir 'data-global' 'selection'
	local global_selection_dir="$REPLY"

	if [ ! -f "$global_selection_dir/$plugin_name" ]; then
		core.print_die "Failed to find (global) default for plugin '$plugin_name'"
	fi

	unset -v REPLY; REPLY= # TODO: make this everywhere
	REPLY=$(<"$global_selection_dir/$plugin_name")
}

util.plugin_set_global_version() {
	local plugin_name="$1"
	local plugin_version="$2"

	var.get_dir 'data-global' 'selection'
	local global_selection_dir="$REPLY"
	if [ -d "$global_selection_dir" ]; then
		mkdir -p "$global_selection_dir"
	fi
	if ! printf '%s\n' "$plugin_version" > "$global_selection_dir/$plugin_name"; then
		core.print_die "Failed to write new global version to disk"
	fi
	core.print_info "Set version '$plugin_version' as global version"
}

util.plugin_get_local_version() {
	local plugin_name="$1"

	# TODO: directory semantics instead of file
	if var.get_tty_dir; then
		local selected_plugin_file="$REPLY/$plugin_name"

		if [ ! -f "$selected_plugin_file" ]; then
		core.print_die "Failed to find (global) default for plugin '$plugin_name'"
	fi
		unset -v REPLY; REPLY= # TODO: make this everywhere
		REPLY=$(<"$selected_plugin_file")
	else
		core.print_die "Failed because standard input is not a tty"
	fi
}

util.plugin_set_local_version() {
	# TODO: directory semantics instead of file
	local plugin_name="$1"
	local plugin_version="$2"

	if var.get_tty_dir; then
		local selected_plugin_file="$REPLY/$plugin_name"
		if [ ! -d "${selected_plugin_file%/*}" ]; then
			mkdir -p "${selected_plugin_file%/*}"
		fi
		if ! printf '%s\n' "$plugin_version" > "$selected_plugin_file"; then
			core.print_die "Failed to write new tty-specific version to disk"
		fi
		core.print_info "Set version '$plugin_version' as tty-specific version"
	else
		core.print_die "Failed because standard input is not a tty"
	fi
}
