# shellcheck shell=bash

# @description Installs a particular plugin
helper.plugin_install() {
	util.plugin_prune

	local flag_force="$1"
	if ! shift; then
		util.print_fatal_die 'Failed to shift'
	fi

	local plugin_uris=()

	if [ -z "$1" ]; then
		helper.determine_plugin_uri "$plugin_name"
		plugin_uris=("$REPLY")
	else
		plugin_uris=("$@")
	fi

	local plugin_uri=
	for plugin_uri in "${plugin_uris[@]}"; do
		if [[ $plugin_uri =~ ^[a-zA-Z0-9_-]+$ ]]; then
			plugin_uri="https://github.com/version-manager/woof-plugin-$plugin_uri"
		fi
		if [[ $plugin_uri != https://* ]]; then
			plugin_uri="https://$plugin_uri"
		fi

		util.plugin_resolve_external_path "$plugin_uri"
		local plugin_type="$REPLY_TYPE"
		local plugin_src="$REPLY_SRC"
		local plugin_target="$REPLY_TARGET"

		if [ "$plugin_type" = 'symlink' ]; then
			util.plugin_assert_is_valid "$plugin_src"

			if [ "$flag_force" = 'no' ]; then
				if [ -d "$plugin_target" ]; then
					core.print_warn "Plugin is already installed: $plugin_target"
					continue
				fi
			fi

			util.mkdirp "${plugin_target%/*}"

			if ln -sfT "$plugin_src" "$plugin_target"; then :; else
				util.print_error_die "Failed to symlink plugin directory"
			fi
		elif [ "$plugin_type" = 'git-repository' ]; then
			if [ "$flag_force" = 'no' ]; then
				if [ -d "$plugin_target" ]; then
					core.print_warn "Plugin is already installed: $plugin_target"
					continue
				fi
			fi

			util.mkdirp "${plugin_target%/*}"
			if git clone --quiet "$plugin_src" "$plugin_target"; then :; else
				util.print_error_die "Failed to clone Git repository"
			fi
			util.print_info "Cloned: $plugin_target"

			util.plugin_assert_is_valid "$plugin_target"
		else
			util.print_error_die "Failed to recognize plugin type: '$plugin_type'"
		fi
	done; unset -v plugin_uri
}

# @description Uninstalls a particular set of plugins
helper.plugin_uninstall() {
	util.plugin_prune

	local plugin_names=()

	if [ -z "$1" ]; then
		helper.determine_plugin "$plugin_name"
		plugin_names=("$REPLY")
	else
		plugin_names=("$@")
	fi

	var.get_dir 'plugins'
	local plugins_dir="$REPLY"

	local plugin_name=
	for plugin_name in "${plugin_names[@]}"; do
		local plugin_dir="$plugins_dir/woof-plugin-$plugin_name"

		if [ -L "$plugin_dir" ]; then
			unlink "$plugin_dir"
			core.print_warn "Unlinked plugin: $plugin_name"
		else
			rm -rf "${plugin_dir?:}"
			core.print_warn "Deleted plugin: $plugin_name"
		fi
	done; unset -v plugin_name
}

# @description Enables a particular set of plugins
helper.plugin_enable() {
	util.plugin_prune

	local plugin_names=()

	if [ -z "$1" ]; then
		helper.determine_plugin "$plugin_name"
		plugin_names=("$REPLY")
	else
		plugin_names=("$@")
	fi

	local plugin_name=
	for plugin_name in "${plugin_names[@]}"; do
		if util.plugin_is_enabled "$plugin_name"; then
			core.print_warn "Plugin already enabled: $plugin_name"
		else
			util.plugin_set_enabled "$plugin_name"
			util.print_info "Enabled plugin: $plugin_name"
		fi
	done; unset -v plugin_name
}

# @description Disables a particular set of plugins
helper.plugin_disable() {
	util.plugin_prune

	local plugin_names=()

	if [ -z "$1" ]; then
		helper.determine_plugin "$plugin_name"
		plugin_names=("$REPLY")
	else
		plugin_names=("$@")
	fi

	local plugin_name=
	for plugin_name in "${plugin_names[@]}"; do
		if util.plugin_is_enabled "$plugin_name"; then
			util.plugin_set_disabled "$plugin_name"
			util.print_info "Disabled plugin: $plugin_name"
		else
			core.print_warn "Plugin already disabled: $plugin_name"
		fi
	done; unset -v plugin_name
}

# @description Prints information about a set of plugins
helper.plugin_info() {
	util.plugin_prune

	local plugin_names=()

	if [ -z "$1" ]; then
		helper.determine_plugin "$plugin_name"
		plugin_names=("$REPLY")
	else
		plugin_names=("$@")
	fi

	var.get_dir 'plugins'
	local plugins_dir="$REPLY"

	local plugin_name=
	for plugin_name in "${plugin_names[@]}"; do
		local plugin_dir="$plugins_dir/woof-plugin-$plugin_name"

		util.plugin_show_one "$plugin_dir"
	done; unset -v plugin_name
}

# @description Prints information about all plugins
helper.plugin_list() {
	util.plugin_prune

	util.plugin_get_plugins --filter=none --with=filepath
	if ((${#REPLY[@]} == 0)); then
		term.style_italic -Pd 'No plugins installed' >&2
		return 0
	fi

	local plugin_dir
	for plugin_dir in "${REPLY[@]}"; do
		util.plugin_show_one "$plugin_dir"
	done; unset -v plugin_dir
}