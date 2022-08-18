# shellcheck shell=bash

woof-plugin-uninstall() {
	local specified_plugin="$1"

	if ! util.pluginmeta_is_plugin_installed "$specified_plugin"; then
		core.print_die "Plugin '$specified_plugin' is not installed"
	fi
}
