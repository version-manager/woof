# shellcheck shell=bash

woof-get-version() {
	local possible_module_name="$1"
	local possible_version_string="$2"

	helper.determine_module_name "$possible_module_name"
	local module_name="$REPLY"

	# Get version choice
	var.get_symlink_dir 'global' 'choice'
	local global_choice_dir="$REPLY"
	printf '%s\n' "$(<"$global_choice_dir/$module_name")"
}
