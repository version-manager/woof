# shellcheck shell=bash

woof-install() {
	local possible_module_name="$1"
	local possible_module_version="$2"

	helper.determine_module_name "$possible_module_name"
	local module_name="$REPLY"
	unset -v possible_module_name
	
	helper.create_version_table "$module_name"

	helper.determine_module_version "$module_name" "$possible_module_version"
	local module_version="$REPLY"
	unset -v possible_module_version

	helper.install_module_version "$module_name" "$module_version"
	helper.symlink_after_install "$module_name" "$module_version"
}
