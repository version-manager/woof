# shellcheck shell=bash

util.get_table_row() {
	unset REPLY{1,2}; REPLY1= REPLY2=
	local tool_name="$1"
	local tool_version="$2"
	local real_os="$3"
	local real_arch="$4"
	util.assert_not_empty 'tool_name'
	util.assert_not_empty 'tool_version'
	util.assert_not_empty 'real_os'
	util.assert_not_empty 'real_arch'

	var.get_plugin_table_file "$tool_name"
	local table_file="$REPLY"

	if [ ! -f "$table_file" ]; then
		util.print_error_die "Expected file '$table_file' to exist"
	fi

	if [ -z "$real_os" ] || [ -z "$real_arch" ]; then
		util.uname_system
		real_os="$REPLY1"
		real_arch="$REPLY2"
	fi

	local variant= version= os= arch= url= comment=
	while IFS='|' read -r variant version os arch url comment; do
		if  [ "$tool_version" = "$version" ] && [ "$real_os" = "$os" ] && [ "$real_arch" = "$arch" ]; then
			REPLY1=$url
			REPLY2=$comment
		fi
	done < "$table_file"; unset -v variant version os arch url comment

	if [ -z "$REPLY1" ]; then
		core.print_error "Failed to find a version $tool_version for $tool_name"
		util.print_hint "Does the version begin with 'v'? (Example: v18.0.0)"
		util.print_hint "Try running 'woof tool clear-version-table $tool_name'"
		exit 1
	fi
}

util.run_function() {
	local flag_optional='no'
	if [ "$1" = '--optional' ]; then
		flag_optional='yes'
		if ! shift; then
			util.print_error_die 'Failed to shift'
		fi
	fi
	local function_name="$1"
	if ! shift; then
		util.print_error_die 'Failed to shift'
	fi

	if declare -f "$function_name" &>/dev/null; then
		core.print_debug 'Executing' "$function_name()"
		if "$function_name" "$@"; then
			return $?
		else
			return $?
		fi
	else
		if [ "$flag_optional" = 'no' ]; then
			util.print_error_die "Function '$function_name' not defined"
		fi
	fi
}

util.key_to_index() {
	unset REPLY; REPLY=

	local -n array_name="$1"
	local key="$2"

	local -i index=-1
	for ((i=0; i<${#array_name[@]}; ++i)); do
		if [ "${array_name[$i]}" = "$key" ]; then
			index=$i
			break
		fi
	done; unset -v i

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
		util.print_error_die "Failed to execute 'uname -s'"
	fi

	if ! hardware="$(uname -m)"; then
		util.print_error_die "Failed to execute 'uname -m'"
	fi

	local kernel_pretty= hardware_pretty=

	# linux|darwin|freebsd
	case "$kernel" in
		Linux) kernel_pretty='linux' ;;
		Darwin) kernel_pretty='darwin' ;;
		FreeBSD) kernel_pretty='freebsd' ;;
		*) util.print_error_die "Kernel '$kernel' unsupported. Please create a bug report if this is a mistake" ;;
	esac

	# x86_64|x86|armv7l|aarch64
	case "$hardware" in
		i686|x86) hardware_pretty='x86' ;;
		amd64|x86_64) hardware_pretty='x86_64' ;;
		armv7l) hardware_pretty='armv7l' ;;
		aarch64) hardware_pretty='aarch64' ;;
		*) util.print_error_die "Hardware '$hardware' unsupported. Please create a bug report if this is a mistake" ;;
	esac

	REPLY1="$kernel_pretty"
	REPLY2="$hardware_pretty"
}

util.get_plugin_data() {
	unset -v REPLY
	declare -g REPLY=()

	local tool_name="$1"
	local tool_version="$2"
	local specified_key="$3"
	util.assert_not_empty 'tool_name'
	util.assert_not_empty 'tool_version'
	util.assert_not_empty 'specified_key'

	var.get_dir 'installed-tools' "$tool_name"
	local install_dir="$REPLY"

	local data_file="$install_dir/$tool_version/.woof__/data.txt"
	local key= values=
	while IFS='=' read -r key values; do
		if [ "$specified_key" = "$key" ]; then
			IFS=':' read -ra values <<< "$values"

			REPLY=("${values[@]}")
			return
		fi
	done < "$data_file"; unset -v key values
}

util.is_tool_version_installed() {
	unset -v REPLY; REPLY=
	local tool_name="$1"
	local tool_version="$2"
	util.assert_not_empty 'tool_name'
	util.assert_not_empty 'tool_version'

	var.get_dir 'installed-tools' "$tool_name"
	local install_dir="$REPLY"

	if [ -f "$install_dir/$tool_version/.woof__/done" ]; then
		REPLY="$install_dir/$tool_version"
		return 0
	else
		return 1
	fi
}

util.assert_not_empty() {
	local variable_name=
	for variable_name; do
		local -n __variable="$variable_name"

		if [ -z "$__variable" ]; then
			util.print_fatal_die "Failed because variable '$variable_name' is empty"
		fi
	done; unset -v variable_name
}

util.sanitize_path() {
	unset -v REPLY; REPLY=
	local path="$1"
	util.assert_not_empty 'path'

	# For now, only do this once (replace '/./' with '/')
	path=${path/\/.\//\/}

	local woof_var_name=
	for woof_var_name in $WOOF_VARS; do
		local -n woof_var="$woof_var_name"

		if [ "${path::${#woof_var}}" = "$woof_var" ]; then
			path="\$$woof_var_name${path:${#woof_var}}"
		fi
	done; unset -v woof_var_name
	unset -vn woof_var

	REPLY="$path"
}

util.sort_versions() {
	sort -V
}

util.mkdirp() {
	local dir="$1"

	if [ ! -d "$dir" ]; then
		mkdir -p "$dir"
	fi
}
