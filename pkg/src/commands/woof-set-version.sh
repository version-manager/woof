# shellcheck shell=bash

woof-set-version() {
	local possible_module_name="$1"
	local possible_version_string="$2"

	helper.determine_module_name "$possible_module_name"
	local module_name="$REPLY"

	helper.determine_version_string_installed "$module_name" "$possible_version_string"
	local version_string="$REPLY"

	# Write version choice
	var.get_symlink_dir 'global' 'choice'
	local global_choice_dir="$REPLY"
	if [ -d "$global_choice_dir" ]; then
		mkdir -p "$global_choice_dir"
	fi
	if ! printf '%s\n' "$version_string" > "$global_choice_dir/$module_name"; then
		print.die "Could not write global version"
	fi
	print.info "Set version '$version_string' as global version"

	# Resymlink
	helper.symlink_after_install "$module_name" "$version_string"
	print.info "Did symlinks for version '$version_string'"
}
