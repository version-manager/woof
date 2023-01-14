# shellcheck shell=bash

woof-uninstall() {
	local -a subcmds=()
	local arg=
	for arg; do case $arg in
	--help)
		util.help_show_usage_and_flags 'uninstall'
		util.help_show_cmd_root 'uninstall'
		exit 0
		;;
	-*)
		util.print_error_die "Flag '$arg' not recognized"
		;;
	*)
		subcmds+=("$arg")
	esac done; unset -v arg

	local possible_tool_name="${subcmds[0]}"
	local possible_tool_version="${subcmds[1]}"

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
