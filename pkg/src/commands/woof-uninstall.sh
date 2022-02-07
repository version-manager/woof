# shellcheck shell=bash

# TODO: unset set-system, etc.
woof-uninstall() {
	local possible_module_name="$1"
	local possible_version_string="$2"

	helper.determine_installed_module_name "$possible_module_name"
	local module_name="$REPLY"

	helper.determine_installed_version_string "$module_name" "$possible_version_string"
	local version_string="$REPLY"

	unset -v possible_module_name
	unset -v possible_version_string

	local install_dir="$WOOF_DATA_HOME/installs/$module_name/$version_string"
	local install_dir_data="$WOOF_DATA_HOME/installs/$module_name/$version_string-data.txt"

	# Do uninstall
	printf '%s\n' "Uninstalling $module_name"
	rm -f "$install_dir_data"
	if [ -e "$install_dir" ]; then
		rm -rf "$install_dir"
		print.info "Removed version '$version_string' for module '$module_name'"
	else
		print.info "Version '$version_string' for module '$module_name' is not installed"
	fi
}
