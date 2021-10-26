# shellcheck shell=bash

# TODO: unset set-system, etc.
woof-uninstall() {
	local module_name="$1"
	local version_string="$2"

	local install_dir="$WOOF_DATA_HOME/installs/$module_name/$version_string"
	local install_dir_data="$WOOF_DATA_HOME/installs/$module_name/$version_string-data.txt"

	rm -f "$install_dir_data"
	if [ -e "$install_dir" ]; then
		rm -rf "$install_dir"
		print.info "Removed version '$version_string' for module '$module_name'"
	else
		print.die "Version '$version_string' for module '$module_name' is not installed"
	fi
}
