# shellcheck shell=bash

woof-plugin-list() {
	local -a subcmds=()
	local arg=
	for arg; do case $arg in
	--help)
		util.help_show_usage_and_flags 'plugin list'
		util.help_show_cmd_plugin 'list'
		exit 0
		;;
	-*)
		util.print_error_die "Flag '$arg' not recognized"
		;;
	*)
		subcmds+=("$arg")
		;;
	esac done; unset -v arg

	var.get_dir 'installed-plugins'
	local plugins_dir="$REPLY"

	for plugin_dir in "$plugins_dir"/*; do
		util.plugin_show_one "$plugin_dir"
	done; unset -v
}
