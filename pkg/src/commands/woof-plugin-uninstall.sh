# shellcheck shell=bash

woof-plugin-uninstall() {
	local specified_plugin="$1"

	if util.plugin_is_installed "$specified_plugin"; then
		local type="$REPLY_TYPE"
		local dir="$REPLY_DIR"

		if [ "$type" = 'symlink' ]; then
			unlink "$dir"
		elif [ "$type" = 'git' ]; then
			rm -rf "${dir:?}"
		fi
	else
		util.print_error_die "Plugin '$specified_plugin' is not installed"
	fi
}
