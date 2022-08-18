# shellcheck shell=bash

woof-uninstall() {
	local possible_plugin_name="$1"
	local possible_plugin_version="$2"

	helper.determine_plugin_name_installed "$possible_plugin_name"
	local plugin_name="$REPLY"
	unset -v possible_plugin_name

	helper.determine_plugin_version_installed "$plugin_name" "$possible_plugin_version"
	local plugin_version="$REPLY"
	unset -v possible_plugin_version

	var.get_dir 'installs' "$plugin_name"
	local install_dir="$REPLY"

	# Do uninstall
	printf '%s\n' "Uninstalling $plugin_name"
	if [ -e "$install_dir/$plugin_version" ]; then # TODO: redundant because helper.determine_plugin_version_installed
		rm -rf "${install_dir:?}/$plugin_version"
		core.print_info "Removed version '$plugin_version' for plugin '$plugin_name'"
	else
		core.print_error "Version '$plugin_version' for plugin '$plugin_name' is not installed"
	fi
}
