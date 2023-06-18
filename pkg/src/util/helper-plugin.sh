# shellcheck shell=bash

# @description Installs a symlink plugin. Assumes that the src is a valid directory that's a plugin
helper.plugin_install() {
	local plugin_type="$1"
	local plugin_src="$2"
	local plugin_target="$3"
	local flag_force="$4"


	if [ "$plugin_type" = 'symlink' ]; then
		util.plugin_assert_is_valid "$plugin_src"

		if [ "$flag_force" = 'no' ]; then
			if [ -d "$plugin_target" ]; then
				util.print_error_die "Plugin '$plugin_src' is already installed"
			fi
		fi

		util.mkdirp "${plugin_target%/*}"

		if ln -sfT "$plugin_src" "$plugin_target"; then :; else
			util.print_error_die "Failed to symlink plugin directory"
		fi
	elif [ "$plugin_type" = 'git-repository' ]; then
		if [ "$flag_force" = 'no' ]; then
			if [ -d "$plugin_target" ]; then
				util.print_error_die "Plugin '$plugin_src' is already installed"
			fi
		fi

		util.mkdirp "${plugin_target%/*}"
		if git clone "$plugin_src" "$plugin_target"; then :; else
			util.print_error_die "Failed to clone Git repository"
		fi

		util.plugin_assert_is_valid "$plugin_target"
	else
		util.print_error_die "Failed to recognize plugin type: '$plugin_type'"
	fi
}

helper.plugin_uninstall() {
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
	done
}

helper.plugin_enable() {
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
	done
}

helper.plugin_disable() {
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
	done
}

helper.plugin_info() {
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
	done
}

# @description Lists all plugins in nice format
helper.plugin_list() {
	util.plugin_get_plugins --filter=none --with=filepath
	local plugin_dir
	for plugin_dir in "${REPLY[@]}"; do
		util.plugin_show_one "$plugin_dir"
	done; unset -v plugin_dir
}
