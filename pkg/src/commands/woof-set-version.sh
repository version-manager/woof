# shellcheck shell=bash

woof-set-version() {
	local possible_module_name="$1"
	local possible_module_version="$2"

	helper.determine_module_name "$possible_module_name"
	local module_name="$REPLY"
	unset -v possible_module_name

	helper.determine_module_version_installed "$module_name" "$possible_module_version"
	local module_version="$REPLY"
	unset -v possible_module_version

	# Write version selection
	var.get_dir 'global' 'selection'
	local global_selection_dir="$REPLY"
	if [ -d "$global_selection_dir" ]; then
		mkdir -p "$global_selection_dir"
	fi
	if ! printf '%s\n' "$module_version" > "$global_selection_dir/$module_name"; then
		core.print_die "Could not write global version"
	fi
	core.print_info "Set version '$module_version' as global version"

	# Resymlink
	helper.symlink_after_install "$module_name" "$module_version"
	core.print_info "Did symlinks for version '$module_version'"
}
