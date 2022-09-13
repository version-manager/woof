# shellcheck shell=bash

woof-plugin-uninstall() {
	local plugin="$1"

	if [ -z "$plugin" ]; then
		util.print_error_die "Passed plugin cannot be empty"
	fi

	util.plugin_prune

	util.plugin_resolve_internal_path "$plugin"
	local plugin_target="$REPLY"

	util.plugin_uninstall "$plugin_target"
}
