# shellcheck shell=bash

util.get_table_row() {
	unset REPLY{1,2}; REPLY1= REPLY2=
	local module_name="$1"
	local module_version="$2"
	local real_os="$3"
	local real_arch="$4"

	var.get_module_table_file "$module_name"
	local table_file="$REPLY"

	if [ ! -f "$table_file" ]; then
		core.print_fatal "File '$table_file' does not exist, but was expected to"
	fi

	if [ -z "$real_os" ] || [ -z "$real_arch" ]; then
		util.uname_system
		real_os="$REPLY1"
		real_arch="$REPLY2"
	fi

	local variant= version= os= arch= url= comment=
	while IFS='|' read -r variant version os arch url comment; do
		if  [ "$module_version" = "$version" ] && [ "$real_os" = "$os" ] && [ "$real_arch" = "$arch" ]; then
			REPLY1=$url
			REPLY2=$comment
			return 0
		fi
	done < "$table_file"; unset -v variant version os arch url comment

	if [ -z "$REPLY1" ] || [ -z "$REPLY2" ]; then
		core.print_error "Failed to find corresponding row in version table"
		util.print_hint "Does the version begin with 'v'? (Example: v18.0.0)"
		util.print_hint "Try running 'woof tool clear-version-table $module_name'"
		exit 1
	fi

	return 1
}

util.run_function() {
	local flag_optional='no'
	if [ "$1" = '--optional' ]; then
		flag_optional='yes'
		if ! shift; then
			core.panic 'Failed to shift'
		fi
	fi
	local function_name="$1"
	if ! shift; then
		core.panic 'Failed to shift'
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
			core.panic "Function '$function_name' not defined"
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
		*) core.print_die "Kernel '$kernel' unsupported. Please create a bug report if this is a mistake" ;;
	esac

	# x86_64|x86|armv7l|aarch64
	case "$hardware" in
		i686|x86) hardware_pretty='x86' ;;
		amd64|x86_64) hardware_pretty='x86_64' ;;
		armv7l) hardware_pretty='armv7l' ;;
		aarch64) hardware_pretty='aarch64' ;;
		*) core.print_die "Hardware '$hardware' unsupported. Please create a bug report if this is a mistake" ;;
	esac

	REPLY1="$kernel_pretty"
	REPLY2="$hardware_pretty"
}

util.get_module_data() {
	unset -v REPLY
	declare -g REPLY=()

	local module_name="$1"
	local module_version="$2"
	local specified_key="$3"

	var.get_dir 'installs' "$module_name"
	local install_dir="$REPLY"

	local data_file="$install_dir/$module_version/data.txt"
	local key= values=
	while IFS='=' read -r key values; do
		IFS=':' read -ra values <<< "$values"

		if [ "$specified_key" = "$key" ]; then
			REPLY=("${values[@]}")
			return
		fi
	done < "$data_file"; unset -v key values
}

util.get_global_selection() {
	unset REPLY; REPLY=
	local module_name="$1"

	var.get_dir 'global' 'selection'
	local global_selection_file="$REPLY/$module_name"

	local global_selection=
	if [ -f "$global_selection_file" ]; then
		if ! global_selection=$(<"$global_selection_file"); then
			core.print_die "Could not read from '$global_selection_file'"
		fi
	fi

	REPLY=$global_selection
}

util.set_global_selection() {
	unset REPLY; REPLY=
	local module_name="$1"
	local module_version="$2"

	var.get_dir 'global' 'selection'
	local global_selection_file="$REPLY/$module_name"
	core.print_info "Setting $module_version as global default for $module_name"
	if [ ! -d "${global_selection_file%/*}" ]; then
		mkdir -p "${global_selection_file%/*}"
	fi
	if ! printf '%s\n' "$module_version" > "$global_selection_file"; then
		rm -f "$global_selection_file"
		core.print_die "Could not write to '$global_selection_file'"
	fi
}

util.is_module_version_installed() {
	unset -v REPLY; REPLY=
	local module_name="$1"
	local module_version="$2"

	var.get_dir 'installs' "$module_name"
	local install_dir="$REPLY"

	if [ -d "$install_dir/$module_version/done" ]; then
		return $?
	else
		return $?
	fi
}

util.get_current_module_version() {
	local module_name="$1"

	var.get_dir 'global' 'selection'
	local global_selection_dir="$REPLY"

	if [ ! -f "$global_selection_dir/$module_name" ]; then
		core.print_die "Could not find (global) default for module '$module_name'"
	fi

	unset -v REPLY; REPLY= # TODO: make this everywhere
	REPLY=$(<"$global_selection_dir/$module_name")
}

util.assert_not_empty() {
	local variable_name=
	for variable_name; do
		local -n __variable="$variable_name"

		if [ -z "$__variable" ]; then
			core.panic "Failed because variable '$variable_name' is empty"
		fi
	done; unset -v variable_name
}

util.sanitize_path() {
	unset -v REPLY; REPLY=
	local path="$1"

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

util.print_hint() {
	printf '%s\n' "  -> $1"
}

util.show_help() {
	printf '%s\n' "Usage:
   woof init <shell>
   woof <subcommand> [module] [version]

Subcommands:
    init <shell>
        Print code for a particular shell to set the proper PATH, etc.

    install [--no-cache]
        Install a particular program

    uninstall
        Uninstall a particular program

    get-version
        Get the current version of a program

    set-version
        Set the current version of a program

    list [--installed] [--all]
        List programs

    tool <resymlink|info|print-dirs|cd-override|debug-table|debug-install|
        clear-table-cache> [... args]
            Run a particular tool Most of these are for internal use
"
}
