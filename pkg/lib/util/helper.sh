# shellcheck shell=bash

helper.get_module_name() {
	unset REPLY; REPLY=
	local module_name="$1"

	if [ -z "$module_name" ]; then
		print.die "No module was given"
	fi

	local plugin_file="$BASALT_PACKAGE_DIR/pkg/lib/modules/$module_name.sh"
	if [ ! -f "$plugin_file" ]; then
		print.die "Module '$module_name' not found"
	fi

	if ! source "$plugin_file"; then
		print.die "Could not successfully source module '$module_name'"
	fi

	REPLY="$module_name"
}

# @description For a given module, construct a matrix of all versions for all
# platforms (kernel and architecture). Each key looks like 'v0.8.6|linux|x86'
# while each value looks like 'https://nodejs.org/download/release/v0.8.6/
# node-v0.8.6-linux-x86.tar.gz|(Released 2012-08-06)'
helper.create_version_matrix() {
	local module_name="$1"

	local matrix_file="$WOOF_DATA_HOME/cached/$module_name-matrix.txt"
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
	if [ -z "$version_string" ]; then
		local -a matrix_key=()
		local -A matrix_table=()

		while IFS=' ' read -r key value; do
			matrix_key+=("$key")
			matrix_table["$key"]="$value"
		done < "$matrix_file"; unset key value

		helper.select_version "$module_name" 'matrix_key' 'matrix_table'
		version_string="$REPLY"
	fi

	if ! util.get_matrix_value_from_key "$module_name" "$version_string"; then
		print.die "Version '$version_string' is not valid for module '$module_name'"
	fi

	REPLY="$version_string"
}

helper.get_current_system_attributes() {
	unset REPLY{1,2}; REPLY1= REPLY2=
	local kernel= hardware=

	if ! kernel="$(uname -s)"; then
		die "Could not 'uname -s'"
	fi

	if ! hardware="$(uname -m)"; then
		die "Could not 'uname -m'"
	fi

	local kernel_pretty= hardware_pretty=

	# linux|darwin|freebsd
	case "$kernel" in
		Linux)
			;;
		Darwin)
			;;
		FreeBSD)
			;;
	esac
	kernel_pretty='linux'

	# amd64|x86|armv7l|aarch64
	case "$hardware" in
		x86)
			;;
		ia64)
			;;
		amd64|x86_64)
			;;
		sparc64)
			;;
	esac
	hardware_pretty='amd64'

	REPLY1="$kernel_pretty"
	REPLY2="$hardware_pretty"
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

	# Current choice
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

	helper.get_current_system_attributes
	local current_kernel="$REPLY1"
	local current_architecture="$REPLY2"

	for key in "${matrix_key_variable[@]}"; do
		local value="${matrix_table_variable["$key"]}"

		local old_ifs="$IFS"; IFS='|'
		local version_string= kernel= architecture=
		read -r version_string kernel architecture <<< "$key"
		IFS="$old_ifs"

		if [ "$current_kernel" = "$kernel" ] && [ "$current_architecture" = "$architecture" ]; then
				ui_keys+=("$version_string")
				ui_table["$version_string"]="$value"
		fi

		unset version_string kernel architecture
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
