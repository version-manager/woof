# shellcheck shell=bash

helper.determine_module_name() {
	unset REPLY; REPLY=
	local module_name="$1"

	if [ -z "$module_name" ]; then
		local -a all_modules_arr=("$BASALT_PACKAGE_DIR/pkg/src/modules"/*.sh)
		all_modules_arr=("${all_modules_arr[@]##*/}")
		all_modules_arr=("${all_modules_arr[@]%.sh}")

		local -A all_modules_obj=()
		for m in "${all_modules[@]}"; do
			all_modules_obj["$m"]=
		done; unset m

		tty.multiselect "$global_selection" all_modules_arr all_modules_obj
		module_name="$REPLY"
	fi

	local plugin_file="$BASALT_PACKAGE_DIR/pkg/src/modules/$module_name.sh"
	if [ ! -f "$plugin_file" ]; then
		core.print_die "Module '$module_name' not found"
	fi

	if ! source "$plugin_file"; then
		core.print_die "Could not successfully source module '$module_name'"
	fi

	REPLY=$module_name
}

helper.determine_module_name_installed() {
	unset REPLY; REPLY=
	local module_name="$1"

	var.get_module_install_dir "$module_name"
	local install_dir="$REPLY"

	if [ -z "$module_name" ]; then
		core.shopt_push -s nullglob
		local -a module_list=("$install_dir"/*/)
		core.shopt_pop

		if (( ${#module_list[@]} == 0 )); then
			core.print_die "Cannot uninstall as no modules are installed"
		fi

		module_list=("${module_list[@]%/}")
		module_list=("${module_list[@]##*/}")

		local -A modules_table=()
		local module=
		for module in "${module_list[@]}"; do
			modules_table["$module"]=
		done; unset module

		tty.multiselect 0 module_list modules_table
		module_name=$REPLY
	fi

	if [ ! -d "$install_dir" ]; then
		core.print_die "No versions of module '$module_name' are installed"
	fi

	REPLY=$module_name
}

helper.determine_module_version() {
	unset REPLY; REPLY=
	local module_name="$1"
	local module_version="$2"

	var.get_module_table_file "$module_name"
	local table_file="$REPLY"

	util.uname_system
	local real_os="$REPLY1"
	local real_arch="$REPLY2"

	if [ -z "$module_version" ]; then
		local -a ui_keys=()
		local -A ui_table=()

		local match_found='no'
		local version= os= arch= url= comment=
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

		util.get_global_selection "$module_name"
		local global_selection="$REPLY"

		tty.multiselect "$global_selection" ui_keys ui_table
		module_version="$REPLY"
	fi

	local is_valid_string='yes'
	local variant= version= os= arch= url= comment=
	while IFS='|' read -r variant version os arch url comment; do
		if [ "$module_version" = "$version" ] && [ "$real_os" = "$os" ] && [ "$real_arch" = "$arch" ]; then
			is_valid_string='yes'
		fi
	done < "$table_file"; unset variant version os arch url comment

	if [ "$is_valid_string" != yes ]; then
		core.print_die "Version '$module_version' is not valid for module '$module_name' on this architecture"
	fi

	REPLY=$module_version
}

# @description Get the installed version string, if one was not already specified
helper.determine_module_version_installed() {
	local module_name="$1"
	local module_version="$2"

	var.get_module_install_dir "$module_name"
	local install_dir="$REPLY"

	if [ -z "$module_version" ]; then
		core.shopt_push -s nullglob
		local -a versions_list=("$install_dir"/*/)
		core.shopt_pop

		if (( ${#versions_list[@]} == 0 )); then
			core.print_die "Cannot uninstall as no versions of module '$module_name' are installed"
		fi

		versions_list=("${versions_list[@]%/}")
		versions_list=("${versions_list[@]##*/}")

		local -A versions_table=()
		local version=
		for version in "${versions_list[@]}"; do
			versions_table["$version"]=
		done; unset version

		util.get_global_selection "$module_name"
		local global_selection="$REPLY"

		tty.multiselect "$global_selection" versions_list versions_table
		module_version="$REPLY"
	fi

	if [ ! -d "$install_dir/$module_version" ]; then
		core.print_die "Version '$module_version' is not valid for module '$module_name'"
	fi
}
