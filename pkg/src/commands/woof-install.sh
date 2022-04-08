# shellcheck shell=bash

woof-install() {
	local possible_module_name="$1"
	local possible_version_string="$2"

	helper.determine_module_name "$possible_module_name"
	local module_name="$REPLY"
	unset -v possible_module_name

	helper.create_version_matrix "$module_name"

	helper.determine_version_string "$module_name" "$possible_version_string"
	local version_string="$REPLY"
	unset -v possible_version_string

	helper.install_module_version "$module_name" "$version_string"
	helper.symlink_after_install "$module_name" "$version_string"
}
