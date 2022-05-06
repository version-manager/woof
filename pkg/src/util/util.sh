# shellcheck shell=bash

util.assert_not_empty() {
	local variable_name=
	for variable_name; do
		local -n __variable="$variable_name"

		if [ -z "$__variable" ]; then
			print.die "Failed because variable '$variable_name' is empty"
		fi
	done; unset -v variable_name
}

util.run_function() {
	local function_name="$1"
	if ! shift; then 
		print.die 'Failed to shift'
	fi

	if ! declare -f "$function_name" >/dev/null 2>&1; then
		print.die "Function '$function_name' not defined"
	fi

	print.info 'Executing' "$function_name()"
	if "$function_name" "$@"; then
		return $?
	else
		return $?
	fi
}

util.get_matrix_row() {
	unset REPLY{1,2}; REPLY1= REPLY2=
	local module_name="$1"
	local version_string="$2"
	local real_os="$3"
	local real_arch="$4"

	var.get_cached_matrix_file "$module_name"
	local matrix_file="$REPLY"

	if [ ! -f "$matrix_file" ]; then
		print.fatal "File '$matrix_file' does not exist, but was expected to"
	fi

	if [ -z "$real_os" ] || [ -z "$real_arch" ]; then
		util.uname_system
		real_os="$REPLY1"
		real_arch="$REPLY2"
	fi
	
	local variant= version= os= arch= url= comment=
	while IFS='|' read -r variant version os arch url comment; do
		if  [ "$version_string" = "$version" ] && [ "$real_os" = "$os" ] && [ "$real_arch" = "$arch" ]; then
			REPLY1=$url
			REPLY2=$comment
			return 0
		fi
	done < "$matrix_file"; unset -v variant version os arch url comment

	if [ -z "$REPLY1" ] || [ -z "$REPLY2" ]; then
		print.die "Faield to find corresponding row"
	fi

	return 1
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

util.get_module_data() {
	unset -v REPLY
	declare -g REPLY=()
	
	local module_name="$1"
	local version_string="$2"
	local specified_key="$3"

	var.get_module_install_dir "$module_name"
	local install_dir="$REPLY"

	local data_file="$install_dir/$version_string/data.txt"
	local key= values=
	while IFS='=' read -r key values; do
		IFS=':' read -ra values <<< "$values"

		if [ "$specified_key" = "$key" ]; then
			REPLY=("${values[@]}")
			return
		fi
	done < "$data_file"; unset -v key values
}

util.get_current_selection() {
	unset REPLY; REPLY=
	local module_name="$1"

	var.get_dir 'global' 'selection'
	local current_selection_file="$REPLY/$module_name"

	local current_selection=
	if [ -f "$current_selection_file" ]; then
		if ! current_selection="$(<"$current_selection_file")"; then
			print.die "Could not read from '$current_selection_file'"
		fi
	fi

	REPLY=$current_selection
}

util.set_current_selection() {
	unset REPLY; REPLY=
	local module_name="$1"
	local current_selection="$2"

	var.get_dir 'global' 'selection'
	local current_selection_file="$REPLY/$module_name"

	mkdir -p "${current_selection_file%/*}"
	if ! printf '%s\n' "$version_string" > "$current_selection_file"; then
		rm -f "$current_selection_file"
		print.die "Could not write to '$current_selection_file'"
	fi
}

util.is_module_version_installed() {
	unset -v REPLY; REPLY=
	local module_name="$1"
	local version_string="$2"

	var.get_module_install_dir "$module_name"
	local install_dir="$REPLY"

	if [ -d "$install_dir/$version_string/done" ]; then
		return $?
	else
		return $?
	fi
}

util.toolversions_get_path() {
	local toolversions_file='.tool-versions'
	local toolversions_path=
	if ! toolversions_path=$(
		while [ ! -f "$toolversions_file" ] && [ "$PWD" != / ]; do
			if ! cd ..; then
				exit 1
			fi
		done
		if [ "$PWD" = / ]; then
			exit
		fi
		printf '%s' "$PWD/$toolversions_file"
	); then
		print.die "Could not find '$toolversions_file'"
	fi
}

util.show_help() {
	printf '%s\n' "Usage:
   woof init <shell>
   woof <action> [module] [version]

Actions:
   init <shell>
   install
   uninstall
   get-version
   set-version
   list [--installed] [--all]
   tool <debug-matrix|debug-install|clear-matrix-cache> [... args]
"
}
