# shellcheck shell=bash

woof-set-version() {
	local possible_plugin_name="$1"
	local possible_plugin_version="$2"

	helper.determine_plugin_name "$possible_plugin_name"
	local plugin_name="$REPLY"
	unset -v possible_plugin_name

	helper.determine_plugin_version_installed "$plugin_name" "$possible_plugin_version"
	local plugin_version="$REPLY"
	unset -v possible_plugin_version

	# Write version selection
	var.get_dir 'global' 'selection'
	local global_selection_dir="$REPLY"
	if [ -d "$global_selection_dir" ]; then
		mkdir -p "$global_selection_dir"
	fi
	if ! printf '%s\n' "$plugin_version" > "$global_selection_dir/$plugin_name"; then
		core.print_die "Failed to write new global version to disk"
	fi
	core.print_info "Set version '$plugin_version' as global version"

	# Resymlink
	helper.symlink_after_install "$plugin_name" "$plugin_version"
	core.print_info "Symlinked version '$plugin_version'"
}
