# shellcheck shell=bash

woof-get-version() {
	local possible_module_name="$1"

	helper.determine_module_name "$possible_module_name"
	local module_name="$REPLY"
	unset -v possible_module_name

	util.get_current_module_version "$module_name"
	local version="$REPLY"

	printf '%s\n' "$REPLY"
}
