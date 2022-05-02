# shellcheck shell=bash

woof-get-version() {
	local possible_module_name="$1"

	helper.determine_module_name "$possible_module_name"
	local module_name="$REPLY"
	unset -v possible_module_name

	var.get_dir 'global' 'selection'
	local global_selection_dir="$REPLY"

	if [ ! -f "$global_selection_dir/$module_name" ]; then
		print.die "Could not find (global) default for module '$module_name'"
	fi

	printf '%s\n' "$(<"$global_selection_dir/$module_name")"
}
