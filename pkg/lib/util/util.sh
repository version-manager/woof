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

util.get_module_value_from_key() {
	unset REPLY; REPLY=
	local module_name="$1"
	local version_string="$2"

	local matrix_file="$WOOF_DATA_HOME/cached/$module_name-matrix.txt"
	if [ ! -f "$matrix_file" ]; then
		print.fatal "File '$matrix_file' does not exist, but was expected to"
	fi

	while IFS=' ' read -r key value; do
		local old_ifs="$IFS"; IFS='|'
		local version= kernel= architecture=
		read -r version kernel architecture <<< "$key"
		IFS="$old_ifs"

		if [ "$version_string" = "$version" ]; then
			REPLY="$value"
			return 0
		fi
	done < "$matrix_file"; unset key value

	return 1
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
