# shellcheck shell=bash

woof-plugin-uninstall() {
	local -a plugins=()
	local arg=
	for arg; do case $arg in
	--help)
		util.help_show_usage_and_flags 'plugin uninstall'
		util.help_show_part '.plugin.uninstall'
		exit 0
		;;
	-*)
		util.print_help_die '.plugin.uninstall' "Flag '$arg' not recognized"
		;;
	*)
		plugins+=("$arg")
	esac done; unset -v arg

	local plugin="${plugins[0]}"

	if [ -z "$plugin" ]; then
		util.print_help_die '.plugin.uninstall' "Passed plugin cannot be empty"
	fi

	var.get_dir 'plugins'
	local plugin_dir="$REPLY/$plugin"

	if [ ! -d "$plugin_dir" ]; then
		util.print_error_die "Plugin does not exist: ${plugin_dir##*/}"
	fi

	util.plugin_uninstall "$plugin_dir"
}
