# shellcheck shell=bash

woof-uninstall() {
	local possible_module_name="$1"
	local possible_module_version="$2"

	helper.determine_module_name_installed "$possible_module_name"
	local module_name="$REPLY"
	unset -v possible_module_name

	helper.determine_module_version_installed "$module_name" "$possible_module_version"
	local module_version="$REPLY"
	unset -v possible_module_version

	var.get_module_install_dir "$module_name"
	local install_dir="$REPLY"

	# Do uninstall
	printf '%s\n' "Uninstalling $module_name"
	if [ -e "$install_dir/$module_version" ]; then
		rm -rf "${install_dir:?}/$module_version"
		print.info "Removed version '$module_version' for module '$module_name'"
	else
		print.info "Version '$module_version' for module '$module_name' is not installed"
	fi
}
