# shellcheck shell=bash

woof-plugin-install() {
	local plugin="$1"

	if util.plugin_is_installed "$plugin"; then
		core.print.die "Plugin '$plugin' already installed"
	fi

	plugin=${plugin%/}
	if [ "${plugin::2}" = './' ]; then
		plugin=$(readlink -f "$plugin")

		util.plugin_install_with_symlink 'symlink' "$plugin"
	elif [ "${plugin::1}" = '/' ]; then
		util.plugin_install_with_symlink 'symlink' "$plugin"
	fi

	if [ "${plugin::1}" = '/' ]; then
		var.get_dir 'installed-plugins'
		local installed_plugins_dir="$REPLY"

		util.plugin_install_with_symlink 'symlink' "$plugin" "$installed_plugins_dir"
	fi

	# TODO
	# if [[ "$specified_plugin" =~ ^github\.com/(.*?)/(.*) ]]; then
	# 	local repo_owner="${BASH_REMATCH[1]}"
	# 	local repo_name="${BASH_REMATCH[2]}"

	# 	util.plugin_install_with_git 'git_repository' "$specified_plugin" "$installed_plugins_dir"
	# fi
}
