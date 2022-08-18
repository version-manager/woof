# shellcheck shell=bash

util.pluginmeta_is_plugin_installed() {
	unset -v REPLY; REPLY=
	local specified_plugin="$1"

	uitl.pluginmeta_parse_pluginlist
	local entry=
	for entry in "${REPLY[@]}"; do
		local plugin_type="${entry%%|*}"
		local plugin_place="${entry#*|}"

		var.get_dir 'installed-plugins'
		local installed_plugins_dir="$REPLY"

		if [ "$specified_plugin" = "$plugin_place" ]; then
			return 0
		fi

		installed_plugins_dir=$(readlink -f "$installed_plugins_dir")
		echo "$installed_plugins_dir/${specified_plugin##*/}"
		if [ "$specified_plugin" = "$installed_plugins_dir/${specified_plugin##*/}" ]; then
			return 0
		fi
	done; unset -v entry

	return 1
}

util.pluginmeta_install_symlink() {
	local plugin_type="$1"
	local plugin_place="$2"
	local target_dir="$3"

	# Ensure specified path is a directroy
	if [ ! -d "$plugin_place" ]; then
		core.print_die "Path at '$plugin_place' is not a directory"
	fi

	if ! util.pluginmeta_is_plugin_installed "$plugin_place"; then
		if [ ! -d "$target_dir" ]; then
			mkdir -p "$target_dir"
		fi

		if ln -sfT "$plugin_place" "$target_dir/${plugin_place##*/}"; then :; else
			core.print_die "Failed to symlink plugin directory"
		fi

		util.pluginmeta_add_to_list "$plugin_type" "$plugin_place"
	else
		core.print_die "Plugin '$plugin_place' is already installed"
	fi
}

util.pluginmeta_add_to_list() {
	local plugin_type="$1"
	local plugin_place="$2"

	var.get_dir 'common'
	local plugin_list_file="$REPLY/plugin-list.txt"

	if [ ! -d "${plugin_list_file%/*}" ]; then
		mkdir -p "${plugin_list_file%/*}"
	fi

	if ! printf '%s\n' "$plugin_type|$plugin_place" >> "$plugin_list_file"; then
		core.print_die "Failed to write to file '$plugin_list_file'"
	fi
}

uitl.pluginmeta_parse_pluginlist() {
	var.get_dir 'common'
	local plugin_list_file="$REPLY/plugin-list.txt"

	unset -v REPLY; declare -ag REPLY=()

	if [ -f "$plugin_list_file" ]; then
		local line=
		while IFS='|' read -r line; do
			REPLY+=("$line")
		done < "$plugin_list_file"; unset -v line
	fi
}
