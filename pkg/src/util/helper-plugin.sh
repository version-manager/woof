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
	local plugin_dir="$1"

	if [ -L "$plugin_dir" ]; then
		unlink "$plugin_dir"
	else
		rm -rf "${plugin_dir?:}"
	fi
}

helper.plugin_enable() {
	local plugin_slug="$1"

	var.get_dir 'data-state'
	local global_state_dir="$REPLY"

	if [ ! -d "$global_state_dir" ]; then
		mkdir -p "$global_state_dir"
	fi
	touch "$global_state_dir/installed_plugins"
	local -a installed_plugins=("$plugin_slug")
	local line=
	while IFS= read -r line; do
		if [ -z "$line" ]; then
			continue
		fi

		if [ "$line" = "$plugin_slug" ]; then
			# Already enabled
			return
		fi

		installed_plugins+=("$line")
	done < "$global_state_dir/installed_plugins"
	unset -v line

	local file_content=
	local plugin_slug=
	for plugin_slug in "${installed_plugins[@]}"; do
		file_content+="$plugin_slug"$'\n'
	done; unset -v plugin_slug

	printf '%s' "$file_content" > "$global_state_dir/installed_plugins"

}

helper.plugin_disable() { # TODO
	:
}
