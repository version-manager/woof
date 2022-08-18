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
		local dir="$REPLY"

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
		local dir="$REPLY"

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
