# shellcheck shell=bash

woof-plugin-install() {
	local specified_plugin="$1"

	if util.plugin_is_installed "specified_plugin"; then
		core.print.die "Plugin '$specified_plugin' already installed"
	fi

	var.get_dir 'installed-plugins'
	local installed_plugins_dir="$REPLY"

	if [ "${specified_plugin::2}" = './' ]; then
		specified_plugin=$(readlink -f "$specified_plugin")

		util.plugin_install_with_symlink 'symlink' "$specified_plugin" "$installed_plugins_dir"
	elif [ "${specified_plugin::1}" = '/' ]; then
		util.plugin_install_with_symlink 'symlink' "$specified_plugin" "$installed_plugins_dir"
	elif [[ "$specified_plugin" =~ ^github\.com/(.*?)/(.*) ]]; then
		local repo_owner="${BASH_REMATCH[1]}"
		local repo_name="${BASH_REMATCH[2]}"
		printf '%s\n' "Should clone github.com/$repo_owner/$repo_name" # TODO
	fi
}
