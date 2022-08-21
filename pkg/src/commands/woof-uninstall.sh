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

	var.get_dir 'installed-tools' "$plugin_name"
	local install_dir="$REPLY"

	# Do uninstall
	printf '%s\n' "Uninstalling $plugin_name"
	# Note that this is a redundant check since it is done by helper.determine_plugin_version_installed(), but we
	# do it anyways, Just in Case
	if [ -e "$install_dir/$plugin_version" ]; then
		rm -rf "${install_dir:?}/$plugin_version"
		util.print_info "Removed version '$plugin_version' for plugin '$plugin_name'"
	else
		core.print_die "Version '$plugin_version' for plugin '$plugin_name' is not installed"
	fi
}
