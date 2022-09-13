# shellcheck shell=bash

util.plugin_parse_manifest() {
	unset -v REPLY_{SLUG,NAME,DESC,TAGS}
	declare -ag REPLY_TAGS=()

	local manifest_file="$1"
	util.assert_not_empty 'manifest_file'

	# shellcheck disable=SC1007
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

util.plugin_resolve_path() {
	var.get_dir 'installed-plugins'
	local plugins_dir="$REPLY"

	unset -v REPLY_{SRC,TARGET,TYPE}; REPLY_SRC= REPLY_TARGET= REPLY_TARGET=
	local plugin="$1"

	plugin=${plugin%/}
	if [ "${plugin::2}" = './' ]; then
		REPLY_TYPE='symlink'
		REPLY_SRC=$(readlink -f "$plugin")
		REPLY_TARGET="$plugins_dir/local/${plugin##*/}"
	elif [ "${plugin::1}" = '/' ]; then
		REPLY_TYPE='symlink'
		REPLY_SRC=$plugin
		REPLY_TARGET="$plugins_dir/local/${plugin##*/}"
	else
		util.print_error_die "Passed plugin must be an absolute or relative path"
	fi
}

util.plugin_resolve_internal_path() {
	var.get_dir 'installed-plugins'
	local plugins_dir="$REPLY"

	local plugin="$1"

	if [ ! -d "$plugins_dir/$plugin" ]; then
		util.print_error_die "Plugin not installed: $plugin"
	fi

	REPLY="$plugins_dir/$plugin"
}

util.plugin_assert_is_valid() {
	local plugin_type="$1"
	local plugin_dir="$2"

	if [ ! -d "$plugin_dir" ]; then
		util.print_error_die "Plugin directory does not exist: '$plugin_dir'"
	fi

	if [ ! -f "$plugin_dir/manifest.ini" ]; then
		util.print_error_die "No plugin found at path: $plugin_dir"
	fi
}

util.plugin_prune() {
	var.get_dir 'installed-plugins'
	local plugins_dir="$REPLY"

	core.shopt_push -s nullglob

	local file=
	for file in "$plugins_dir"/*; do
		if [ ! -e "$file" ]; then
			unlink "$file"
		fi
	done

	core.shopt_pop
}

# @description Installs a symlink plugin. Assumes that the src is a valid directory that's a plugin
util.plugin_install() {
	local plugin_type="$1"
	local plugin_src="$2"
	local plugin_target="$3"

	if [ "$plugin_type" = 'symlink' ]; then
		if [ -d "$plugin_target" ]; then
			util.print_error_die "Plugin '$plugin_src' is already installed"
		else
			util.mkdirp "${plugin_target%/*}"

			if ln -sfT "$plugin_src" "$plugin_target"; then :; else
				util.print_error_die "Failed to symlink plugin directory"
			fi
		fi
	fi
}

util.plugin_uninstall() {
	local plugin_target="$1"

	if [ -L "$plugin_target" ]; then
		unlink "$plugin_target"
	else
		rm -rf "${plugin_target?:}"
	fi
}
