# shellcheck shell=bash

# @description Tool names aren't required to be specified on the command line. If one
# isn't specified, then start a TUI selection screen
helper.determine_tool_pair() {
	unset -v REPLY; REPLY=
	local input="$1"

	local tool_pair=
	local plugin_name=
	local tool_name=

	if [ -z "$input" ]; then
		util.plugin_get_plugins --filter=active --with=name
		local -a all_plugins_arr=("${REPLY[@]}")
		local -A all_plugins_obj=()
		for m in "${all_plugins_arr[@]}"; do
			all_plugins_obj["$m"]=
		done; unset -v m
		tty.multiselect '' all_plugins_arr all_plugins_obj
		plugin_name="$REPLY"

		util.plugin_get_active_tools_of_plugin "$plugin_name"
		local all_tools_arr=("${REPLY[@]}")
		local -A all_tools_obj=()
		for m in "${all_tools_arr[@]}"; do
			all_tools_obj["$m"]=
		done; unset -v m
		tty.multiselect '' all_tools_arr all_tools_obj
		tool_name="$REPLY"

		tool_pair="$plugin_name/$tool_name"
	elif [[ "$input" != */* ]]; then
		util.plugin_get_active_tools --with=pair
		local tools=("${REPLY[@]}")

		local tool=
		for tool in "${tools[@]}"; do
			if [ "$input" = "${tool#*/}" ]; then
				plugin_name=${tool%/*}
				tool_name=${tool#*/}

				tool_pair="$plugin_name/$tool_name"
				break
			fi
		done

		if [ -z "$tool_name" ]; then

			util.plugin_get_active_tools_of_plugin "$input"
			local all_tools_arr=("${REPLY[@]}")
			local -A all_tools_obj=()
			for m in "${all_tools_arr[@]}"; do
				all_tools_obj["$m"]=
			done; unset -v m
			tty.multiselect '' all_tools_arr all_tools_obj
			local _tool_name="$REPLY"

			plugin_name=$input
			tool_name="$_tool_name"

			tool_pair="$plugin_name/$tool_name"
		fi
	else
		plugin_name=${input%/*}
		tool_name=${input#*/}

		tool_pair=$input
	fi

	var.get_tool_file "$plugin_name" "$tool_name"
	local tool_file="$REPLY"

	if [ ! -f "$tool_file" ]; then
		util.print_error_die "Tool '$input' not found"
	fi

	# shellcheck source=/dev/null
	if ! source "$tool_file"; then # TODO: REMOVE THIS
		util.print_error_die "Could not successfully source plugin '$tool_pair'"
	fi

	REPLY=$tool_pair
	REPLY1=$plugin_name
	REPLY2=$tool_name
}

helper.determine_tool_pair_installed() {
	unset -v REPLY; REPLY=
	local tool_pair="$1"

	var.get_dir 'tools' "$tool_pair"
	local install_dir="$REPLY"

	if [ -z "$tool_pair" ]; then
		core.shopt_push -s nullglob
		local -a plugin_list=("$install_dir"/*/)
		core.shopt_pop

		if (( ${#plugin_list[@]} == 0 )); then
			util.print_error_die "Cannot uninstall as no plugins are installed"
		fi

		plugin_list=("${plugin_list[@]%/}")
		plugin_list=("${plugin_list[@]##*/}")

		local -A plugins_table=()
		local plugin=
		for plugin in "${plugin_list[@]}"; do
			plugins_table["$plugin"]=
		done; unset plugin

		tty.multiselect 0 plugin_list plugins_table
		tool_pair=$REPLY
	fi

	if [ ! -d "$install_dir" ]; then
		util.print_error_die "No versions of plugin '$tool_pair' are installed"
	fi

	REPLY=$tool_pair
}

helper.determine_tool_version() {
	unset -v REPLY; REPLY=
	local flag_allow_latest='no'
	if [ "$1" = '--allow-latest' ]; then
		flag_allow_latest='yes'
		if ! shift; then
			print.panic 'Failed to shift'
		fi
	fi
	local tool_version="$1"

	util.uname_system
	local real_os="$REPLY1"
	local real_arch="$REPLY2"

	if [[ "$flag_allow_latest" = 'yes' && "$tool_version" = 'latest' ]]; then
		helper.determine_latest_tool_version "$g_tool_pair" "$real_os" "$real_arch"
		tool_version="$REPLY"
	fi

	var.get_plugin_table_file "$g_tool_pair"
	local table_file="$REPLY"

	if [ -z "$tool_version" ]; then
		local -a ui_keys=()
		local -A ui_table=()

		local match_found='no'
		local variant= version= os= arch= url= comment=
		while IFS='|' read -r variant version os arch url comment; do
			if [ "$real_os" = "$os" ] && [ "$real_arch" = "$arch" ]; then
				match_found='yes'
				ui_keys+=("$version")
				ui_table["$version"]="$url $comment"
			fi
		done < "$table_file"; unset -v version os arch url comment

		if [ "$match_found" != 'yes' ]; then
			util.print_error_die "Could not find any matching versions for the current os/arch"
		fi

		util.tool_get_global_version --no-error "$g_tool_pair"
		local tool_version_global="$REPLY"

		tty.multiselect "$tool_version_global" ui_keys ui_table
		tool_version="$REPLY"
	fi

	local is_valid_string='yes'
	local variant= version= os= arch= url= comment=
	while IFS='|' read -r variant version os arch url comment; do
		if [ "$tool_version" = "$version" ] && [ "$real_os" = "$os" ] && [ "$real_arch" = "$arch" ]; then
			is_valid_string='yes'
		fi
	done < "$table_file"; unset -v variant version os arch url comment

	if [ "$is_valid_string" != yes ]; then
		util.print_error_die "Version '$tool_version' is not valid for plugin '$g_tool_pair' on this architecture"
	fi

	REPLY=$tool_version
}

# @description Get the installed version string, if one was not already specified
helper.determine_tool_version_installed() {
	local tool_pair="$1"
	local tool_version="$2"

	var.get_dir 'tools' "$g_tool_pair"
	local install_dir="$REPLY"

	if [ -z "$g_tool_version" ]; then
		core.shopt_push -s nullglob
		local -a versions_list=("$install_dir"/*/)
		core.shopt_pop

		if (( ${#versions_list[@]} == 0 )); then
			util.print_error_die "Cannot uninstall as no versions of plugin '$g_tool_pair' are installed"
		fi

		versions_list=("${versions_list[@]%/}")
		versions_list=("${versions_list[@]##*/}")

		local -A versions_table=()
		local version=
		for version in "${versions_list[@]}"; do
			versions_table["$version"]=
		done; unset -v version

		util.tool_get_global_version --no-error "$g_tool_pair"
		local tool_version_global="$REPLY"

		tty.multiselect "$tool_version_global" versions_list versions_table
		tool_version="$REPLY"
	fi

	if [ ! -d "$install_dir/$tool_version" ]; then
		util.print_error_die "Version '$tool_version' is not valid for plugin '$g_tool_pair'"
	fi

	REPLY="$tool_version"
}

helper.determine_latest_tool_version() {
	unset -v REPLY; REPLY=
	local tool_pair="$1"
	local real_os="$2"
	local real_arch="$3"
	util.assert_not_empty 'tool_pair'
	util.assert_not_empty 'real_os'
	util.assert_not_empty 'real_arch'

	var.get_plugin_table_file "$g_tool_pair"
	local table_file="$REPLY"

	local variant= version= os= arch= url= comment=
	while IFS='|' read -r variant version os arch url comment; do
		if [ "$real_os" = "$os" ] && [ "$real_arch" = "$arch" ]; then
			REPLY="$version"
			break
		fi
	done < "$table_file"; unset -v version os arch url comment
}

helper.determine_plugin() {
	local plugin_name="$1"

	if [ -z "$plugin_name" ]; then
		util.plugin_get_plugins --filter=none --with=name

		local -a plugins_list=("${REPLY[@]}")
		local -A plugins_table=()
		local plugin=
		for plugin in "${plugins_list[@]}"; do
			plugins_table["$plugin"]=
		done; unset -v plugin

		tty.multiselect '' plugins_list plugins_table
		plugin_name=$REPLY
	fi

	var.get_dir 'plugins'
	local plugins_dir="$REPLY"

	local dir="$plugins_dir/woof-plugin-$plugin_name"
	if [ ! -d "$dir" ]; then
		util.print_error_die "Plugin '$plugin_name' is not valid (non-existent directory: $dir)"
	fi

	unset -v REPLY; REPLY=
	REPLY=$plugin_name
}

helper.determine_plugin_uri() {
	local plugin_uri="$1"

	if [ -z "$plugin_uri" ]; then
		local -a plugins_list=(
			'github.com/version-manager/woof-plugin-core'
			'github.com/version-manager/woof-plugin-ancillary'
			'github.com/version-manager/woof-plugin-hashicorp'
		)
		local -A plugins_table=()
		local plugin=
		for plugin in "${plugins_list[@]}"; do
			plugins_table["$plugin"]=
		done; unset -v plugin

		tty.multiselect '' plugins_list plugins_table
		plugin_uri=$REPLY
	fi

	unset -v REPLY; REPLY=
	REPLY=$plugin_uri
}
