# shellcheck shell=bash

woof-plugin-uninstall() {
	local -a plugins=()
	local arg=
	for arg; do case $arg in
	--help)
		util.help_show_usage_and_flags 'plugin uninstall'
		util.help_show_cmd_plugin 'uninstall'
		exit 0
		;;
	-*)
		util.print_error_die "Flag '$arg' not recognized"
		;;
	*)
		plugins+=("$arg")
	esac done; unset -v arg

	local plugin="${plugins[0]}"

	if [ -z "$plugin" ]; then
		util.print_error_die "Passed plugin cannot be empty"
	fi

	util.plugin_prune

	util.plugin_resolve_internal_path "$plugin"
	local plugin_target="$REPLY"

	util.plugin_uninstall "$plugin_target"
}
