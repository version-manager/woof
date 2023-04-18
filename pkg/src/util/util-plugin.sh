# shellcheck shell=bash


# @description Installs a symlink plugin. Assumes that the src is a valid directory that's a plugin
util.plugin_install() {
	local plugin_type="$1"
	local plugin_src="$2"
	local plugin_target="$3"
	local flag_force="$4"

	util.plugin_assert_is_valid "$plugin_src"

	if [ "$plugin_type" = 'symlink' ]; then
		if [ "$flag_force" = 'no' ]; then
			if [ -d "$plugin_target" ]; then
				util.print_error_die "Plugin '$plugin_src' is already installed"
			fi
		fi

		util.mkdirp "${plugin_target%/*}"

		if ln -sfT "$plugin_src" "$plugin_target"; then :; else
			util.print_error_die "Failed to symlink plugin directory"
		fi
	fi
}

util.plugin_uninstall() {
	local plugin_dir="$1"

	if [ -L "$plugin_dir" ]; then
		unlink "$plugin_dir"
	else
		rm -rf "${plugin_dir?:}"
	fi
}

util.plugin_enable() {
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

util.plugin_disable() {
	:
}

util.plugin_resolve_external_path() {
	var.get_dir 'plugins'
	local plugins_dir="$REPLY"

	unset -v REPLY_{SRC,TARGET,TYPE}; REPLY_SRC= REPLY_TARGET= REPLY_TARGET=
	local plugin="$1"

	plugin=${plugin%/}
	if [ "${plugin::2}" = './' ]; then
		REPLY_TYPE='symlink'
		REPLY_SRC=$(readlink -f "$plugin")
		REPLY_TARGET="$plugins_dir/${plugin##*/}"
	elif [ "${plugin::1}" = '/' ]; then
		REPLY_TYPE='symlink'
		REPLY_SRC=$plugin
		REPLY_TARGET="$plugins_dir/${plugin##*/}"
	else
		util.print_error_die "Passed plugin must be an absolute or relative path"
	fi
}

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


util.plugin_assert_is_valid() {
	local plugin_dir="$1"

	if [ ! -d "$plugin_dir" ]; then
		util.print_error_die "Plugin does not exist at: '$plugin_dir'"
	fi

	if [ ! -f "$plugin_dir/manifest.ini" ]; then
		util.print_error_die "Plugin manifest does not exist at: $plugin_dir"
	fi

	# This will fatal if various keys could not be found
	util.plugin_parse_manifest "$plugin_dir/manifest.ini"
	local plugin_slug="$REPLY_SLUG"

	if [ "$plugin_slug" != "${plugin_dir##*/}" ]; then
		util.print_error_die "Plugin with slug '$plugin_slug' does not match the dirname of its path: $plugin_dir"
	fi
}

util.plugin_show_one() {
	local plugin_dir="$1"

	util.plugin_assert_is_valid "$plugin_dir"

	util.plugin_parse_manifest "$plugin_dir/manifest.ini"
	local name="$REPLY_NAME" desc="$REPLY_DESC"
	core.ifs_save
	IFS=', '; tags="${REPLY_TAGS[*]}"
	core.ifs_restore


	local plugin_slug=${plugin_dir##*/}

	term.color_light_blue -Pd "$plugin_slug:"

	term.color_orange 'name:'
	printf '    %s\e[0m %s\n' "$REPLY" "$name"
	# term.style_reset -Pd # TODO

	term.color_orange 'desc:'

	printf '    %s\e[0m %s\n' "$REPLY" "$desc"
	# term.style_reset -Pd # TODO

	term.color_orange 'tags:'
	printf '    %s\e[0m %s\n' "$REPLY" "${tags:-N/A}"
	# term.style_reset -Pd # TODO
}

util.plugin_prune() {
	var.get_dir 'plugins'
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

util.plugin_get_builtin_plugin_list() {
	unset -v REPLY; declare -ga REPLY=()

	core.shopt_push -s nullglob
	# shellcheck disable=SC1007
	local dir= plugin_{owner,name}=
	for dir in "$BASALT_PACKAGE_DIR/pkg/src/plugins"/*/; do
		dir=${dir%/}

		REPLY+=("$dir")
	done; unset -v dir
	core.shopt_pop
}

