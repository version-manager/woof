# shellcheck shell=bash

util.init() {
	trap tty.fullscreen_init SIGCONT
	trap 'tty.fullscreen_deinit; exit' EXIT SIGHUP SIGABRT SIGINT SIGQUIT SIGTERM SIGTSTP

	trap trap.sigwinch SIGWINCH
	trap.sigwinch() {
		read -r global_tty_height global_tty_width < <(stty size)
	}
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

# TODO: pass in real_os, real_os for optimization
util.get_matrix_value_from_key() {
	unset REPLY{1,2}; REPLY1= REPLY2=
	local module_name="$1"
	local real_version="$2"

	local matrix_file="$WOOF_DATA_HOME/cached/$module_name-matrix.txt"
	if [ ! -f "$matrix_file" ]; then
		print.fatal "File '$matrix_file' does not exist, but was expected to"
	fi

	util.uname_system
	local real_os="$REPLY1"
	local real_arch="$REPLY2"

	local version= os= arch= url= comment=
	while IFS='|' read -r version os arch url comment; do
		if util.is_on_platform "$os" "$arch"; then
			REPLY1=$url
			REPLY2=$comment
			return 0
		fi
	done < "$matrix_file"; unset version os arch url comment

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

util.uname_system() {
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
		Linux) kernel_pretty='linux' ;;
		Darwin) kernel_pretty='darwin' ;;
		FreeBSD) kernel_pretty='freebsd' ;;
		*) print.die "Kernel '$kernel' unsupported. Please create a bug report if this is a mistake" ;;
	esac

	# amd64|x86|armv7l|aarch64
	case "$hardware" in
		i686|x86) hardware_pretty='x86' ;;
		amd64|x86_64) hardware_pretty='amd64' ;;
		armv7l) hardware_pretty='armv7l' ;;
		aarch64) hardware_pretty='aarch64' ;;
		*) print.die "Hardware '$hardware' unsupported. Please create a bug report if this is a mistake" ;;
	esac

	REPLY1="$kernel_pretty"
	REPLY2="$hardware_pretty"
}

util.is_on_platform() {
	local os="$1"
	local arch="$2"

	util.uname_system
	real_os=$REPLY1
	real_arch=$REPLY2

	if [ "$real_os" = "$os" ] && [ "$real_arch" = "$arch" ]; then
		return 0
	fi

	return 1
}

util.show_help() {
	printf '%s\n' "Usage:
  woof init <shell>
  woof <action> [module] [version]

Actions: (TODO)
  install
  uninstall
  list
  current
  set-shell
  set-local
  set-global"
}
