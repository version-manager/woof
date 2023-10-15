# shellcheck shell=bash

woof-uninstall() {
	local -a args=()
	local arg=
	for arg; do case $arg in
	--help)
		util.help_show_usage_and_flags 'uninstall'
		util.help_show_part '.uninstall'
		exit 0
		;;
	-*)
		util.print_help_die '.uninstall.' "Flag '$arg' not recognized"
		;;
	*)
		args+=("$arg")
	esac done; unset -v arg

	helper.determine_tool_pair_installed "${args[0]}"
	declare -g g_tool_pair="$REPLY1"
	declare -g g_plugin_name="$REPLY2"
	declare -g g_tool_name="$REPLY3"

	helper.determine_tool_version_installed "$g_tool_pair" "${args[1]}"
	declare -g g_tool_version="$REPLY"

	var.get_dir 'tools' "$g_tool_pair"
	local install_dir="$REPLY"

	# Do uninstall
	printf '%s\n' "Uninstalling $g_tool_pair"
	# Note that this is a redundant check since it is done by helper.determine_tool_version_installed(), but we
	# do it anyways, Just in Case
	if [ -e "$install_dir/$g_tool_version" ]; then
		rm -rf "${install_dir:?}/$g_tool_version"
		util.print_info "Removed version '$g_tool_version' for plugin '$g_tool_pair'"
	else
		util.print_error_die "Version '$g_tool_version' for plugin '$g_tool_pair' is not installed"
	fi

	# Remove the selected tool version if it was just uninstalled.
	var.get_dir 'data'
	local dir="$REPLY/selection"
	local selection_file="$dir/$g_tool_pair"
	local selection=
	selection=$(<"$selection_file")
	if [ "$selection" = "$g_tool_version" ]; then
		rm "$selection_file"
		core.print_warn "You just removed the Go version that was selected by default."
	fi
}
