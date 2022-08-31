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
	unset -v REPLY_{TYPE,DIR}; REPLY_TYPE= REPLY_DIR=
	local plugin="$1"

	var.get_dir 'installed-plugins'
	local plugins_dir="$REPLY"

	plugin=${plugin%/}
	if [ -L "$plugins_dir/$plugin" ]; then
		REPLY_TYPE='symlink'
		REPLY_DIR="$plugins_dir/$plugin"
		return 0
	elif [ -d "$plugins_dir/$plugin" ]; then
		REPLY_TYPE='git'
		REPLY_DIR="$plugins_dir/$plugin"
		return 0
	fi

	return 1
}

util.plugin_install_with_symlink() {
	local plugin_type="$1"
	local plugin_place="$2"

	var.get_dir 'installed-plugins'
	local plugins_dir="$REPLY"

	util.mkdirp "$plugins_dir"

	if ln -sfT "$plugin_place" "$plugins_dir/${plugin_place##*/}"; then :; else
		util.print_error_die "Failed to symlink plugin directory"
	fi

	# Ensure specified path is a directroy
	if [ ! -d "$plugin_place" ]; then
		util.print_error_die "Path at '$plugin_place' is not a directory"
	fi

	if ! util.plugin_is_installed "$plugin_place"; then
		util.mkdirp "$plugins_dir"

		if ln -sfT "$plugin_place" "$plugins_dir/${plugin_place##*/}"; then :; else
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
