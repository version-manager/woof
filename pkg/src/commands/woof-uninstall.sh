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
	local tool_pair="$REPLY"

	helper.determine_tool_version_installed "$tool_pair" "${args[1]}"
	local tool_version="$REPLY"

	var.get_dir 'tools' "$tool_pair"
	local install_dir="$REPLY"

	# Do uninstall
	printf '%s\n' "Uninstalling $tool_pair"
	# Note that this is a redundant check since it is done by helper.determine_tool_version_installed(), but we
	# do it anyways, Just in Case
	if [ -e "$install_dir/$tool_version" ]; then
		rm -rf "${install_dir:?}/$tool_version"
		util.print_info "Removed version '$tool_version' for plugin '$tool_pair'"
	else
		util.print_error_die "Version '$tool_version' for plugin '$tool_pair' is not installed"
	fi
}
