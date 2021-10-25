# shellcheck shell=bash

util.init() {
	trap tty.fullscreen_init SIGCONT
	trap 'tty.fullscreen_deinit; exit' EXIT SIGHUP SIGABRT SIGINT SIGQUIT SIGTERM SIGTSTP

	trap trap.sigwinch SIGWINCH
	trap.sigwinch() {
		read -r global_tty_height global_tty_width < <(stty size)
	}
}

util.versions_from_git() {
	local variable_name="$1"
	local url="$2"
	local prefix="$3"

	local -n variable="$variable_name"
	local prefix_length="${#prefix}"
	while read -r _sha1 refspec; do
		if [ "${refspec:0:$prefix_length}" = "$prefix" ]; then
			variable+=("${refspec:$prefix_length}")
		fi
	done < <(git ls-remote --refs --tags "$url")
	unset _sha1 refspec
}

util.array_filter_out() {
	local array_name="$1"
	local pattern="$2"

	local -n array="$array_name"
	local new_array=("${array[@]}")
	for ((i=0; i<${#array[@]}; i++)); do
		# shellcheck disable=SC2053
		if [[ ${array[i]} != $pattern ]]; then
			new_array+=("${array[i]}")
		fi
	done; unset i

	array=("${new_array[@]}")
	unset new_array
}

util.fetch() {
	if curl -fsS "$@"; then :; else
		return $?
	fi
}

# reply examples 'crystal', 'nodejs', 'go'
util.get_module_name() {
	unset REPLY; REPLY=

	local module_name="${BASH_SOURCE[-3]}"
	module_name="${module_name##*/}"
	module_name="${module_name%.*}"

	if [ -z "$module_name" ]; then
		print.fatal "Variable 'module_name' must not be empty"
	fi

	REPLY="$module_name"
}

util.run_function() {
	local function_name="$1"
	if ! shift; then :; fi

	if ! declare -f "$function_name" >/dev/null 2>&1; then
		print.die "Function '$function_name' not defined"
	fi

	if "$function_name" "$@"; then
		return $?
	else
		return $?
	fi
}

util.is_version_valid() {
	local valid_versions_variable="$1"
	local version="$2"

	local -n valid_versions="$valid_versions_variable"
	for valid_version in "${valid_versions[@]}"; do
		if [ "$valid_version" = "$version" ]; then
			return 0
		fi
	done
	unset valid_version

	return 1
}

util.ensure_cd() {
	if ! cd "$@"; then
		print.die "Could not cd"
	fi
}

# TODO: stub function
util.log() {
	printf '%s\n' "$1" > "/tmp/tmp.G9i2mlntjx/file"
}

util.key_to_index() {
	unset REPLY; REPLY=

	local -n array_name="$1"
	local key="$2"

	local -i index=-1
	for ((i=0; i<${#array_name[@]}; i++)); do
		if [ "${array_name[$i]}" = "$key" ]; then
			index=$i
			break
		fi
	done; unset i

	if ((index == -1)); then
		return 1
	else
		REPLY=$index
	fi
}

util.show_help() {
	cat <<-"EOF"
	Usage:
	  woof --list [--all](TODO)
	  woof <action> <module> [version] # TODO (brackets)

	Actions: (TODO)
	  install
	  uninstall
	  list
	  current
	  where
	  which
	  set-shell
	  set-local
	  set-global
	EOF
}

util.get_current_system_attributes() {
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

# @description For a given module, construct a matrix of all versions for all
# platforms (kernel and architecture). Each key looks like 'v0.8.6|linux|x86'
# while each value looks like 'https://nodejs.org/download/release/v0.8.6/
# node-v0.8.6-linux-x86.tar.gz|(Released 2012-08-06)'. The 'matrix_keys'
# variable is an array of all the keys contained within 'matrix_table'. It is a
# separate variable to make sorting work
util.construct_version_matrix() {
	local module_name="$1"
	local matrix_keys_variable_name="$2"
	local matrix_table_variable_name="$3"

	local -n matrix_key_variable="$matrix_keys_variable_name"
	local -n matrix_table_variable="$matrix_table_variable_name"

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

	while IFS=' ' read -r key value; do
		matrix_key_variable+=("$key")
		matrix_table_variable["$key"]="$value"
	done < "$matrix_file"; unset key value
}

# @description For a particular module, prompt the user for the version
# they want to perform the operation on
util.select_version() {
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

	util.get_current_system_attributes
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

	REPLY="$REPLY|$current_kernel|$current_architecture"
}
