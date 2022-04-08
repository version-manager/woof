# shellcheck shell=bash

woof-uninstall() {
	local possible_module_name="$1"
	local possible_version_string="$2"

	helper.determine_module_name_installed "$possible_module_name"
	local module_name="$REPLY"
	unset -v possible_module_name

	helper.determine_version_string_installed "$module_name" "$possible_version_string"
	local version_string="$REPLY"
	unset -v possible_version_string

	var.get_module_install_dir "$module_name"
	local install_dir="$REPLY"

	# Do uninstall
	printf '%s\n' "Uninstalling $module_name"
	if [ -e "$install_dir/$version_string" ]; then
		rm -rf "${install_dir:?}/$version_string"
		print.info "Removed version '$version_string' for module '$module_name'"
	else
		print.info "Version '$version_string' for module '$module_name' is not installed"
	fi
}
