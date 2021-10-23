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

	if ! declare -f "$function_name" >/dev/null 2>&1; then
		print.die "Function '$function_name' not defined"
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

util.wcl() {
	unset REPLY; REPLY=

	local file="$1"

	local -i i=0
	while IFS= read -r line; do
		i=$((i++))
	done < "$file"
	unset line

	REPLY=$i
}

util.get_detected() {
	local kernel_name="$(uname -s)"
	local machine_hardware="$(uname -m)"

	case "$kernel_name" in
		Linux)
			;;
		Darwin)
			;;
		FreeBSD)
			;;
	esac

	case "$machine_hardware" in
		x86)
			;;
		ia64)
			;;
		amd64|x86_64)
			;;
		sparc64)
			;;
	esac

	REPLY1="x86_64"
	REPLY2=""
}

util.ensure_cd() {
	if ! cd "$@"; then
		print.die "Could not cd"
	fi
}

util.show_help() {
	cat <<-"EOF"
	Usage:
	  woof --list [--all](TODO)
	  woof [module] [action] [version] # TODO (brackets)

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
