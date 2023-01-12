# shellcheck shell=bash

helper.determine_tool_name() {
	unset REPLY; REPLY=
	local tool_name="$1"

	if [ -z "$tool_name" ]; then
		local -a all_tools_arr=("$BASALT_PACKAGE_DIR/pkg/src/plugins"/*/tools/*.sh)
		all_tools_arr=("${all_tools_arr[@]##*/}")
		all_tools_arr=("${all_tools_arr[@]%.sh}")

		local -A all_tools_obj=()
		for m in "${all_tools_arr[@]}"; do
			all_tools_obj["$m"]=
		done; unset -v m

		# TODO: save previous selection here
		tty.multiselect '' all_tools_arr all_tools_obj
		tool_name="$REPLY"
	fi


	local plugin_file=
	local -a plugin_files=("$BASALT_PACKAGE_DIR/pkg/src/plugins"/*/tools/*.sh)
	local f=
	for f in "${plugin_files[@]}";do
		if [[ "$f" == *"$tool_name"* ]]; then
			plugin_file="$f"
		fi
	done; unset -v f
	if [ ! -f "$plugin_file" ]; then
		util.print_error_die "Plugin '$tool_name' not found"
	fi

	if ! source "$plugin_file"; then
		util.print_error_die "Could not successfully source plugin '$tool_name'"
	fi

	REPLY=$tool_name
}

helper.determine_tool_name_installed() {
	unset REPLY; REPLY=
	local tool_name="$1"

	var.get_dir 'installed-tools' "$tool_name"
	local install_dir="$REPLY"

	if [ -z "$tool_name" ]; then
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
		tool_name=$REPLY
	fi

	if [ ! -d "$install_dir" ]; then
		util.print_error_die "No versions of plugin '$tool_name' are installed"
	fi

	REPLY=$tool_name
}

helper.determine_tool_version() {
	unset REPLY; REPLY=
	local flag_allow_latest='no'
	if [ "$1" = '--allow-latest' ]; then
		flag_allow_latest='yes'
		shift || print.panic 'Failed to shift'
	fi
	local tool_name="$1"
	local tool_version="$2"

	util.uname_system
	local real_os="$REPLY1"
	local real_arch="$REPLY2"

	if [[ "$flag_allow_latest" = 'yes' && "$tool_version" = 'latest' ]]; then
		helper.determine_latest_tool_version "$tool_name" "$real_os" "$real_arch"
		tool_version="$REPLY"
	fi

	var.get_plugin_table_file "$tool_name"
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

		util.tool_get_global_version --no-error "$tool_name"
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
		util.print_error_die "Version '$tool_version' is not valid for plugin '$tool_name' on this architecture"
	fi

	REPLY=$tool_version
}

# @description Get the installed version string, if one was not already specified
helper.determine_tool_version_installed() {
	local tool_name="$1"
	local tool_version="$2"

	var.get_dir 'installed-tools' "$tool_name"
	local install_dir="$REPLY"

	if [ -z "$tool_version" ]; then
		core.shopt_push -s nullglob
		local -a versions_list=("$install_dir"/*/)
		core.shopt_pop

		if (( ${#versions_list[@]} == 0 )); then
			util.print_error_die "Cannot uninstall as no versions of plugin '$tool_name' are installed"
		fi

		versions_list=("${versions_list[@]%/}")
		versions_list=("${versions_list[@]##*/}")

		local -A versions_table=()
		local version=
		for version in "${versions_list[@]}"; do
			versions_table["$version"]=
		done; unset version

		util.tool_get_global_version --no-error "$tool_name"
		local tool_version_global="$REPLY"

		tty.multiselect "$tool_version_global" versions_list versions_table
		tool_version="$REPLY"
	fi

	if [ ! -d "$install_dir/$tool_version" ]; then
		util.print_error_die "Version '$tool_version' is not valid for plugin '$tool_name'"
	fi

	REPLY="$tool_version"
}

helper.determine_latest_tool_version() {
	unset -v REPLY; REPLY=
	local tool_name="$1"
	local real_os="$2"
	local real_arch="$3"
	util.assert_not_empty 'tool_name'
	util.assert_not_empty 'real_os'
	util.assert_not_empty 'real_arch'

	var.get_plugin_table_file "$tool_name"
	local table_file="$REPLY"

	local variant= version= os= arch= url= comment=
	while IFS='|' read -r variant version os arch url comment; do
		if [ "$real_os" = "$os" ] && [ "$real_arch" = "$arch" ]; then
			REPLY="$version"
			break
		fi
	done < "$table_file"; unset -v version os arch url comment
}
