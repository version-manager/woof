# shellcheck shell=bash

woof-uninstall() {
	local possible_tool_name="$1"
	local possible_tool_version="$2"

	helper.determine_tool_name_installed "$possible_tool_name"
	local tool_name="$REPLY"
	unset -v possible_tool_name

	helper.determine_tool_version_installed "$tool_name" "$possible_tool_version"
	local tool_version="$REPLY"
	unset -v possible_tool_version

	var.get_dir 'installed-tools' "$tool_name"
	local install_dir="$REPLY"

	# Do uninstall
	printf '%s\n' "Uninstalling $tool_name"
	# Note that this is a redundant check since it is done by helper.determine_tool_version_installed(), but we
	# do it anyways, Just in Case
	if [ -e "$install_dir/$tool_version" ]; then
		rm -rf "${install_dir:?}/$tool_version"
		util.print_info "Removed version '$tool_version' for plugin '$tool_name'"
	else
		util.print_error_die "Version '$tool_version' for plugin '$tool_name' is not installed"
	fi
}
