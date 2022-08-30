# shellcheck shell=bash

util.plugin_is_installed() {
	unset -v REPLY; REPLY=
	local specified_plugin="$1"
	util.assert_not_empty 'specified_plugin'

	uitl.plugin_list_parse
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
		if [ "$specified_plugin" = "$installed_plugins_dir/${specified_plugin##*/}" ]; then
			return 0
		fi
	done; unset -v entry

	return 1
}

util.plugin_install_with_symlink() {
	local plugin_type="$1"
	local plugin_place="$2"
	local target_dir="$3"
	util.assert_not_empty 'plugin_type'
	util.assert_not_empty 'plugin_place'
	util.assert_not_empty 'target_dir'

	if [ ! -f "$plugin_place/manifest.ini" ]; then
		util.print_error_die "Path at '$plugin_place' does not appear to be a directory containing a plugin"
	fi

	# TODO: add force flag
	# Ensure specified path is a directroy
	if [ ! -d "$plugin_place" ]; then
		util.print_error_die "Path at '$plugin_place' is not a directory"
	fi

	if ! util.plugin_is_installed "$plugin_place"; then
		util.mkdirp "$target_dir"

		if ln -sfT "$plugin_place" "$target_dir/${plugin_place##*/}"; then :; else
			util.print_error_die "Failed to symlink plugin directory"
		fi

		util.plugin_list_add "$plugin_type" "$plugin_place"
	else
		util.print_error_die "Plugin '$plugin_place' is already installed"
	fi
}

util.plugin_install_with_git() {
	:
	# TODO
}

util.plugin_list_add() {
	local plugin_type="$1"
	local plugin_place="$2"
	util.assert_not_empty 'plugin_type'
	util.assert_not_empty 'plugin_place'

	var.get_dir 'common'
	local plugin_list_file="$REPLY/plugin-list.txt"

	util.mkdirp "${plugin_list_file%/*}"

	if ! printf '%s\n' "$plugin_type|$plugin_place" >> "$plugin_list_file"; then
		util.print_error_die "Failed to write to file '$plugin_list_file'"
	fi
}

util.plugin_list_remove() {
	:
}

uitl.plugin_list_parse() {
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
