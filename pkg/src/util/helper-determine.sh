# shellcheck shell=bash

helper.determine_plugin_name() {
	unset REPLY; REPLY=
	local plugin_name="$1"

	if [ -z "$plugin_name" ]; then
		local -a all_plugins_arr=("$BASALT_PACKAGE_DIR/pkg/src/plugins"/*.sh)
		all_plugins_arr=("${all_plugins_arr[@]##*/}")
		all_plugins_arr=("${all_plugins_arr[@]%.sh}")

		local -A all_plugins_obj=()
		for m in "${all_plugins[@]}"; do
			all_plugins_obj["$m"]=
		done; unset m

		tty.multiselect "$global_selection" all_plugins_arr all_plugins_obj
		plugin_name="$REPLY"
	fi

	local plugin_file="$BASALT_PACKAGE_DIR/pkg/src/plugins/$plugin_name.sh"
	if [ ! -f "$plugin_file" ]; then
		core.print_die "Plugin '$plugin_name' not found"
	fi

	if ! source "$plugin_file"; then
		core.print_die "Could not successfully source plugin '$plugin_name'"
	fi

	REPLY=$plugin_name
}

helper.determine_plugin_name_installed() {
	unset REPLY; REPLY=
	local plugin_name="$1"

	var.get_dir 'installs' "$plugin_name"
	local install_dir="$REPLY"

	if [ -z "$plugin_name" ]; then
		core.shopt_push -s nullglob
		local -a plugin_list=("$install_dir"/*/)
		core.shopt_pop

		if (( ${#plugin_list[@]} == 0 )); then
			core.print_die "Cannot uninstall as no plugins are installed"
		fi

		plugin_list=("${plugin_list[@]%/}")
		plugin_list=("${plugin_list[@]##*/}")

		local -A plugins_table=()
		local plugin=
		for plugin in "${plugin_list[@]}"; do
			plugins_table["$plugin"]=
		done; unset plugin

		tty.multiselect 0 plugin_list plugins_table
		plugin_name=$REPLY
	fi

	if [ ! -d "$install_dir" ]; then
		core.print_die "No versions of plugin '$plugin_name' are installed"
	fi

	REPLY=$plugin_name
}

helper.determine_plugin_version() {
	unset REPLY; REPLY=
	local flag_allow_latest='no'
	if [ "$1" = '--allow-latest' ]; then
		flag_allow_latest='yes'
		shift || print.panic 'Failed to shift'
	fi
	local plugin_name="$1"
	local plugin_version="$2"

	util.uname_system
	local real_os="$REPLY1"
	local real_arch="$REPLY2"

	if [[ "$flag_allow_latest" = 'yes' && "$plugin_version" = 'latest' ]]; then
		helper.determine_latest_version "$plugin_name" "$real_os" "$real_arch"
		plugin_version="$REPLY"
	fi

	var.get_plugin_table_file "$plugin_name"
	local table_file="$REPLY"

	if [ -z "$plugin_version" ]; then
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
		done < "$table_file"; unset version os arch url comment

		if [ "$match_found" != 'yes' ]; then
			core.print_die "Could not find any matching versions for the current os/arch"
		fi

		util.plugin_get_global_version "$plugin_name"
		local global_selection="$REPLY"

		tty.multiselect "$global_selection" ui_keys ui_table
		plugin_version="$REPLY"
	fi

	local is_valid_string='yes'
	local variant= version= os= arch= url= comment=
	while IFS='|' read -r variant version os arch url comment; do
		if [ "$plugin_version" = "$version" ] && [ "$real_os" = "$os" ] && [ "$real_arch" = "$arch" ]; then
			is_valid_string='yes'
		fi
	done < "$table_file"; unset variant version os arch url comment

	if [ "$is_valid_string" != yes ]; then
		core.print_die "Version '$plugin_version' is not valid for plugin '$plugin_name' on this architecture"
	fi

	REPLY=$plugin_version
}

# @description Get the installed version string, if one was not already specified
helper.determine_plugin_version_installed() {
	local plugin_name="$1"
	local plugin_version="$2"

	var.get_dir 'installs' "$plugin_name"
	local install_dir="$REPLY"

	if [ -z "$plugin_version" ]; then
		core.shopt_push -s nullglob
		local -a versions_list=("$install_dir"/*/)
		core.shopt_pop

		if (( ${#versions_list[@]} == 0 )); then
			core.print_die "Cannot uninstall as no versions of plugin '$plugin_name' are installed"
		fi

		versions_list=("${versions_list[@]%/}")
		versions_list=("${versions_list[@]##*/}")

		local -A versions_table=()
		local version=
		for version in "${versions_list[@]}"; do
			versions_table["$version"]=
		done; unset version

		util.plugin_get_global_version "$plugin_name"
		local global_selection="$REPLY"

		tty.multiselect "$global_selection" versions_list versions_table
		plugin_version="$REPLY"
	fi

	if [ ! -d "$install_dir/$plugin_version" ]; then
		core.print_die "Version '$plugin_version' is not valid for plugin '$plugin_name'"
	fi

	REPLY="$plugin_version"
}

helper.determine_latest_version() {
	unset -v REPLY; REPLY=
	local plugin_name="$1"
	local real_os="$2"
	local real_arch="$3"

	var.get_plugin_table_file "$plugin_name"
	local table_file="$REPLY"

	local variant= version= os= arch= url= comment=
	while IFS='|' read -r variant version os arch url comment; do
		if [ "$real_os" = "$os" ] && [ "$real_arch" = "$arch" ]; then
			REPLY="$version"
			break
		fi
	done < "$table_file"; unset version os arch url comment
}
