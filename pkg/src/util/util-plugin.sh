# shellcheck shell=bash

util.plugin_is_absolute_path() {
	local plugin="$1"
	util.assert_not_empty 'plugin'

	if [ "${plugin::1}" = '/' ]; then
		if [ ! -f "$plugin/manifest.ini" ]; then
			util.print_error_die "No plugin found at path: $plugin"
		fi
		return 0
	else
		return 1
	fi
}

util.is_relative_path() {
	local plugin="$1"
	util.assert_not_empty 'plugin'

	if [ "${plugin::2}" = './' ]; then
		if [ ! -f "$plugin/manifest.ini" ]; then
			util.print_error_die "No plugin found at path: $plugin"
		fi
		return 0
	else
		return 1
	fi
}

util.plugin_parse_manifest() {
	unset -v REPLY_{SLUG,NAME,DESC,TAGS}
	declare -ag REPLY_TAGS=()

	local manifest_file="$1"
	util.assert_not_empty 'manifest_file'

	local key= value=
	while IFS='=' read -r key value || [[ -n "$key" && -n "$value" ]]; do
		key=${key#"${key%%[![:space:]]*}"}
		key=${key%"${key##*[![:space:]]}"}

		value=${value#"${value%%[![:space:]]*}"}
		value=${value%"${value##*[![:space:]]}"}
		if [[ ${value::1} == '"' || ${value::1} == "'" ]]; then
			value=${value:1:-1}
		fi

		if [ "$key" = 'slug' ]; then
			REPLY_SLUG=$value
		elif [ "$key" = 'name' ]; then
			REPLY_NAME=$value
		elif [ "$key" = 'description' ]; then
			REPLY_DESC=$value
		elif [ "$key" = 'tag' ]; then
			REPLY_TAGS+=("$value")
		fi
	done < "$manifest_file"; unset -v key value

	if [ -z "$REPLY_SLUG" ]; then
		util.print_error_die "Key 'slug' must be set in manifest file: $manifest_file"
	fi

	if [ -z "$REPLY_NAME" ]; then
		util.print_error_die "Key 'name' must be set in manifest file: $manifest_file"
	fi
}

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

	util.mkdirp "$target_dir"

	if ln -sfT "$plugin_place" "$target_dir/${plugin_place##*/}"; then :; else
		util.print_error_die "Failed to symlink plugin directory"
	fi

	util.plugin_list_add "$plugin_type" "$plugin_place"
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
