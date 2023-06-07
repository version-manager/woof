# shellcheck shell=bash


# @description Installs a symlink plugin. Assumes that the src is a valid directory that's a plugin
util.plugin_install() {
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

util.plugin_disable() { # TODO
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
	elif [[ "$plugin" == "https://"* ]]; then
		REPLY_TYPE='git-repository'
		REPLY_SRC=$plugin
		REPLY_TARGET="$plugins_dir/${plugin##*/}"
	else
		util.print_error_die "Passed plugin must be an absolute path, relative path, or https URL"
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


util.plugin_assert_is_valid() {
	local plugin_dir="$1"

	if [ ! -d "$plugin_dir" ]; then
		util.print_error_die "Plugin does not exist at directory: '$plugin_dir'"
	fi

	if [ ! -f "$plugin_dir/manifest.ini" ]; then
		util.print_error_die "Plugin manifest does not exist at: $plugin_dir"
	fi

	# This will fatal if various keys could not be found
	util.plugin_parse_manifest "$plugin_dir/manifest.ini"
	local plugin_slug="$REPLY_SLUG"

	if [ "woof-plugin-$plugin_slug" != "${plugin_dir##*/}" ]; then
		util.print_error_die "Plugin with slug '$plugin_slug' does not match the ending of plugin directory $plugin_dir"
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

	printf '    '
	term.color_orange -pd 'name:'
	term.style_reset -pd
	printf ' %s\n' "$name"

	printf '    '
	term.color_orange -pd 'desc:'
	term.style_reset -pd
	printf ' %s\n' "$desc"

	printf '    '
	term.color_orange -pd 'tags:'
	term.style_reset -pd
	printf ' %s\n' "${tags:-N/A}"

	local type=
	if [ -L "$plugin_dir" ]; then
		type='symlink'
	else
		type='git-repository'
	fi
	printf '    '
	term.color_orange -pd 'type:'
	term.style_reset -pd
	printf ' %s\n' "$type"
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

util.plugin_get_active_plugins() {
	var.get_dir 'plugins'
	local plugins_dir="$REPLY"

	unset -v REPLY
	declare -ga REPLY=()

	local dir= plugin_name=
	for dir in "$plugins_dir/"*/; do
		plugin_name=${dir%/}
		plugin_name=${plugin_name##*/}
		plugin_name=${plugin_name#woof-plugin-}

		REPLY+=("$plugin_name")
	done
	unset -v dir plugin
}

util.plugin_get_active_tools_of_plugin() {
	local plugin="$1"

	var.get_dir 'plugins'
	local plugins_dir="$REPLY"

	unset -v REPLY
	declare -ga REPLY=()

	local tool= tool_name=
	for tool in "$plugins_dir/woof-plugin-$plugin/tools/"*.sh; do
		tool_name=${tool##*/}
		tool_name=${tool_name%.sh}

		REPLY+=("$tool_name")
	done
	unset -v tool tool_name
}

util.plugin_get_active_tools() {
	local flag_with='pair'
	local arg=
	for arg; do case $arg in
	--with=*)
		local value=${arg#--with=}
		case $value in
			pair|toolnameonly|toolfileonly)
				flag_with=$value
				;;
			*)
				util.print_error_die "Flag '$arg' could not be evaluated"
				;;
		esac
		;;
	*)
		util.print_error_die "Flag '$arg' not recognized"
		;;
	esac done

	var.get_dir 'plugins'
	local plugins_dir="$REPLY"

	unset -v REPLY
	declare -ga REPLY=()

	local dir= plugin_name= tool=
	for dir in "$plugins_dir/"*/; do
		plugin_name=${dir%/}; plugin_name=${plugin_name##*/}
		plugin_name=${plugin_name#woof-plugin-}
		for tool in "$dir"tools/*.sh; do
			if [ "$flag_with" = 'pair' ]; then
				tool=${tool##*/}; tool=${tool%.sh}

				REPLY+=("${plugin_name}/${tool}")
			elif [ "$flag_with" = 'toolnameonly' ]; then
				tool=${tool##*/}; tool=${tool%.sh}

				REPLY+=("$tool")
			elif [ "$flag_with" = 'toolfileonly' ]; then
				REPLY+=("$tool")
			fi
		done
	done
	unset -v dir plugin tool
}
