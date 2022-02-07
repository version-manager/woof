# shellcheck shell=bash

helper.get_module_name() {
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

		tty.multiselect "$current_choice" all_modules_arr all_modules_obj
		module_name="$REPLY"
	fi

	local plugin_file="$BASALT_PACKAGE_DIR/pkg/src/modules/$module_name.sh"
	if [ ! -f "$plugin_file" ]; then
		print.die "Module '$module_name' not found"
	fi

	if ! source "$plugin_file"; then
		print.die "Could not successfully source module '$module_name'"
	fi

	REPLY=$module_name
}

# @description For a given module, construct a matrix of all versions for all
# platforms (kernel and architecture)
helper.create_version_matrix() {
	local module_name="$1"

	local matrix_file="$WOOF_DATA_HOME/cached/$module_name-matrix.txt"
	if [ ! -d "$WOOF_DATA_HOME/cached" ]; then
		mkdir -p "$WOOF_DATA_HOME/cached"
	fi
	local use_cache=no
	if [ -f "$matrix_file" ]; then
		use_cache=yes
	fi

	if [ "$use_cache" = no ]; then
		local matrix_string=
		if matrix_string="$(util.run_function "$module_name.matrix")"; then
			if err.exists; then
				print.error "$ERR"
				exit "$ERRCODE"
			fi
		else
			print.die "A fatal error occured while running '$module_name.matrix'"
		fi

		if [ -z "$matrix_string" ]; then
			print.die "Function '$module_name.matrix' must output a well-formed matrix of variable names. Nothing was sent"
		fi

		if ! printf '%s' "$matrix_string" > "$matrix_file"; then
			rm -f "$matrix_file"
			print.die "Could not write to '$matrix_file'"
		fi

		unset matrix_string
	fi
}

helper.get_version_string() {
	unset REPLY; REPLY=
	local module_name="$1"
	local version_string="$2"

	local matrix_file="$WOOF_DATA_HOME/cached/$module_name-matrix.txt"
	util.uname_system
	local real_os="$REPLY1"
	local real_arch="$REPLY2"

	if [ -z "$version_string" ]; then
		local -a matrix_key=()
		local -A matrix_table=()

		local version= os= arch= url= comment=
		while IFS='|' read -r version os arch url comment; do
			if [ "$real_os" = "$os" ] && [ "$real_arch" = "$arch" ]; then
				matrix_key+=("$version")
				matrix_table["$version"]="$url $comment"
			fi
		done < "$matrix_file"; unset version os arch url comment

		helper.select_version "$module_name" 'matrix_key' 'matrix_table'
		version_string="$REPLY"
	fi

	local is_valid_string='yes'
	while IFS='|' read -r version os arch url comment; do
		if [ "$version_string" = "$version" ] && [ "$real_os" = "$os" ] && [ "$real_arch" = "$arch" ]; then
			is_valid_string='yes'
		fi
	done < "$matrix_file"; unset version os arch url comment

	if [ "$is_valid_string" != yes ]; then
		print.die "Version '$version_string' is not valid for module '$module_name' on this architecture"
	fi

	REPLY=$version_string
}

# @description Get the installed version string, if one was not already specified
helper.get_installed_version_string() {
	local module_name="$1"
	local version_string="$2"

	if [ -z "$version_string" ]; then
		local -a versions_list=("$WOOF_DATA_HOME/installs/$module_name"/*/)
		versions_list=("${versions_list[@]%/}")
		versions_list=("${versions_list[@]##*/}")

		local -A versions_table=()
		for v in "${versions_list[@]}"; do
			versions_table["$v"]=
		done; unset v

		# Current choice (WET)
		local current_choice_file="$WOOF_STATE_HOME/current-choice/$module_name"
		local current_choice=
		if [ -r "$current_choice_file" ]; then
			if ! current_choice="$(<"$current_choice_file")"; then
				print.die "Could not read from '$current_choice_file'"
			fi
			rm -f "$current_choice_file"
		fi

		tty.multiselect "$current_choice" versions_list versions_table
		version_string="$REPLY"
	fi

	if ! util.get_matrix_value_from_key "$module_name" "$version_string"; then
		print.die "Version '$version_string' is not valid for module '$module_name'"
	fi
}

# @description For a particular module, prompt the user for the version
# they want to perform the operation on. Write the selected version to a
# file (to be the initial value if invoked again), and set REPLY with the
# value
helper.select_version() {
	unset REPLY; REPLY=
	local module_name="$1"
	local matrix_keys_variable_name="$2"
	local matrix_table_variable_name="$3"

	local -n matrix_key_variable="$matrix_keys_variable_name"
	local -n matrix_table_variable="$matrix_table_variable_name"

	# Current choice (WET)
	local current_choice_file="$WOOF_STATE_HOME/current-choice/$module_name"
	local current_choice=
	if [ -r "$current_choice_file" ]; then
		if ! current_choice="$(<"$current_choice_file")"; then
			print.die "Could not read from '$current_choice_file'"
		fi
		rm -f "$current_choice_file"
	fi

	# Similar to 'matrix_key' and 'matrix_key', except this is shown
	# directly to the user in a multiselect screen
	local -a ui_keys=()
	local -A ui_table=()

	local key=
	for key in "${matrix_key_variable[@]}"; do
		local value="${matrix_table_variable["$key"]}"

		ui_keys+=("$key")
		ui_table["$key"]="$value"
	done; unset key

	tty.multiselect "$current_choice" ui_keys ui_table
	local selected_version="$REPLY"

	mkdir -p "${current_choice_file%/*}"
	if ! printf '%s\n' "$selected_version" > "$current_choice_file"; then
		rm -f "$current_choice_file"
		print.die "Could not write to '$current_choice_file'"
	fi

	REPLY="$selected_version"
}
