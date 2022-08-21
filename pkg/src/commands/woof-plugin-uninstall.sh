# shellcheck shell=bash

woof-plugin-uninstall() {
	local specified_plugin="$1"

	if ! util.plugin_is_installed "$specified_plugin"; then
		util.print_error_die "Plugin '$specified_plugin' is not installed"
	fi
}
