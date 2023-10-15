# shellcheck shell=bash

util.plugin_get_plugins() {
	local flag_filter='none'
	local flag_with='none'
	local arg=
	for arg; do case $arg in
	--filter=*)
		local value=${arg#--filter=}
		case $value in
		none|active|installed)
			flag_with=$value
			;;
		*)
			util.print_error_die "Flag '$arg' could not be evaluated"
			;;
		esac
		;;
	--with=*)
		local value=${arg#--with=}
		case $value in
		filepath|name)
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
	esac done; unset -v arg

	var.get_dir 'tools'
	local tools_dir="$REPLY"

	var.get_dir 'plugins'
	local plugins_dir="$REPLY"

	unset -v REPLY
	declare -ga REPLY=()

	local dir= plugin_name= entry=
	core.shopt_push -s nullglob
	for dir in "$plugins_dir/"*/; do
		dir=${dir%/}
		plugin_name=${dir##*/}
		plugin_name=${plugin_name#woof-plugin-}

		if [ "$flag_filter" = 'none' ]; then
			:
		elif [ "$flag_filter" = 'active' ]; then
			if ! util.plugin_is_enabled "$plugin_name"; then
				continue
			fi
		elif [ "$flag_filter" = 'installed' ]; then
			if [ ! -d "$tools_dir/$plugin_name" ]; then
				continue
			fi
		fi

		if [ "$flag_with" = 'filepath' ]; then
			entry=$dir
		elif [ "$flag_with" = 'name' ]; then
			entry=${dir##*/}
			entry=${entry#woof-plugin-}
		fi

		REPLY+=("$entry")
	done
	core.shopt_pop
	unset -v dir plugin_name entry
}

util.plugin_get_plugin_tools() {
	local plugin_name="$1"

	local flag_filter='none'
	local flag_with='none'
	local arg=
	for arg; do case $arg in
	--filter=*)
		local value=${arg#--filter=}
		case $value in
		none|active|installed)
			flag_with=$value
			;;
		*)
			util.print_error_die "Flag '$arg' could not be evaluated"
			;;
		esac
		;;
	--with=*)
		local value=${arg#--with=}
		case $value in
		filepath|name)
			flag_with=$value
			;;
		*)
			util.print_error_die "Flag '$arg' could not be evaluated"
			;;
		esac
		;;
	-*)
		util.print_error_die "Flag '$arg' not recognized"
		;;
	esac done; unset -v arg

	var.get_dir 'plugins'
	local plugins_dir="$REPLY"

	unset -v REPLY
	declare -ga REPLY=()

	local tool= tool_name= entry=
	for tool in "$plugins_dir/woof-plugin-$plugin_name/tools/"*.sh; do
		if [ "$flag_with" = 'filepath' ]; then
			entry=$tool
		elif [ "$flag_with" = 'name' ]; then
			entry=${tool##*/}
			entry=${entry%.sh}
		fi

		REPLY+=("$entry")
	done
	unset -v tool tool_name
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

	if [ -z "$REPLY_NAME" ]; then
		util.print_error_die "Key 'name' must be set in manifest file: $manifest_file"
	fi
}


util.plugin_assert_is_valid() {
	local plugin_dir="$1"

	if [ ! -d "$plugin_dir" ]; then
		util.print_error_die "Plugin could not be found at a non-existent directory: $plugin_dir"
	fi

	if [ ! -f "$plugin_dir/manifest.ini" ]; then
		util.print_error_die "Plugin manifest does not exist in directory: $plugin_dir"
	fi

	# This will fatal if various keys could not be found
	util.plugin_parse_manifest "$plugin_dir/manifest.ini"
}

util.plugin_show_one() {
	local plugin_dir="$1"

	util.plugin_assert_is_valid "$plugin_dir"

	util.plugin_parse_manifest "$plugin_dir/manifest.ini"
	local name="$REPLY_NAME" desc="$REPLY_DESC"
	core.ifs_save
	IFS=', '; tags="${REPLY_TAGS[*]}"
	core.ifs_restore


	local plugin_name=${plugin_dir##*/};
	plugin_name=${plugin_name#woof-plugin-}

	term.color_light_blue -Pd "$plugin_name:"

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

	local enabled='no'
	if util.plugin_is_enabled "$plugin_name"; then
		enabled='yes'
	fi
	printf '    '
	term.color_orange -pd 'enabled:'
	term.style_reset -pd
	printf ' %s\n' "$enabled"
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

util.plugin_is_enabled() {
	local plugin_name="$1"
	util.assert_not_empty 'plugin_name'

	var.get_dir 'data'
	local dir="$REPLY/disabled_plugins"
	util.mkdirp "$dir"

	if [ -f "$dir/$plugin_name" ]; then
		return 1
	else
		return 0
	fi

}

util.plugin_set_disabled() {
	local plugin_name="$1"
	util.assert_not_empty 'plugin_name'

	var.get_dir 'data'
	local dir="$REPLY/disabled_plugins"
	util.mkdirp "$dir"

	touch "$dir/$plugin_name"
}

util.plugin_set_enabled() {
	local plugin_name="$1"
	util.assert_not_empty 'plugin_name'

	var.get_dir 'data'
	local dir="$REPLY/disabled_plugins"
	util.mkdirp "$dir"

	rm -f "$dir/$plugin_name"
}
