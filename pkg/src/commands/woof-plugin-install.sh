# shellcheck shell=bash

woof-plugin-install() {
	local plugin="$1"
	plugin=${plugin%/}

	if util.plugin_is_installed "$plugin"; then
		core.print.die "Plugin '$plugin' already installed"
	fi

	if util.plugin_is_absolute_path "$plugin"; then
		# keep this for manifest.ini check
		:
	elif util.is_relative_path "$plugin"; then
		plugin=$(readlink -f "$plugin")
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
