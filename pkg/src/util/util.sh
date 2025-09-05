# shellcheck shell=bash

util.get_table_row() {
	unset -v REPLY{1,2}; REPLY1= REPLY2=
	local tool_name="$1"
	local tool_version="$2"
	local real_os="$3"
	local real_arch="$4"
	util.assert_not_empty 'tool_name'
	util.assert_not_empty 'tool_version'
	util.assert_not_empty 'real_os'
	util.assert_not_empty 'real_arch'

	var.get_plugin_table_file "$g_tool_pair"
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
	if [ "$1" = '--optional' ]; then # TODO: remove optional?
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
	unset -v REPLY; REPLY=

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
	unset -v REPLY{1,2}; REPLY1= REPLY2=
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

	var.get_dir 'tools' "$tool_name"
	local install_dir="$REPLY"

	local data_file="$install_dir/$tool_version/.woof_/data.txt"
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

	var.get_dir 'tools' "$tool_name"
	local install_dir="$REPLY"

	if [ -f "$install_dir/$tool_version/.woof_/done" ]; then
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

# TODO
util.path_things() {
	# Remove all Woof-related PATH entries
	local new_path=
	local entries=
	IFS=':' read -ra entries <<< "$PATH"
	local entry=
	for entry in "${entries[@]}"; do
		if [[ $entry != *"$WOOF_STATE_HOME"* ]]; then
			new_path="${new_path:+"$new_path:"}$entry"
		fi
	done

	printf '%s\n' '# --- plugins ----'
	util.plugin_get_active_tools --with=toolfileonly
	local tool_file= tool_name=
	for tool_file in "${REPLY[@]}"; do
		# shellcheck disable=SC1090
		source "$tool_file"
		tool_name=${tool_file##*/}; tool_name=${tool_name%*.sh}

		if command -v "$tool_name".env &>/dev/null; then
			printf '%s\n' "# $tool_name"
			"$tool_name".env
			printf '\n'
		fi

		util.tool_get_global_version --no-error "$tool_name"
		local tool_version="$REPLY"
		if [ -n "$tool_version" ]; then
			util.get_plugin_data "$tool_name" "$tool_version" 'bins'
			local -a bins=("${REPLY[@]}")
			local bin=
			for bin in "${bins[@]}"; do
				bin=${bin#./}

				var.get_dir 'tools' "$tool_name"
				local install_dir="$REPLY"
				local bin_dir="$install_dir/$tool_version/$bin"

				new_path="$bin_dir${new_path:+":$new_path"}"
			done; unset -v bin
		fi
	done; unset -v tool_file tool_name

	# Get each currently active global version (for now only global) TODO
	core.shopt_push -s nullglob
	local -a files=("$WOOF_STATE_HOME/data/selection"/*/*)
	core.shopt_pop
	for file in "${files[@]}"; do
		declare -g g_plugin_name=${file%/*}; g_plugin_name=${g_plugin_name##*/}
		declare -g g_tool_name=${file##*/}
		declare -g g_tool_version=
		g_tool_version=$(<"$file")
		declare -g g_tool_pair=$g_plugin_name/$g_tool_name

		# local install_dir="$WOOF_STATE_HOME/tools/$g_tool_name/$g_tool_name/$g_tool_version"
		var.get_dir 'tools' "$g_tool_pair"
		local install_dir="$REPLY/$g_tool_version"

		util.get_plugin_data "$g_tool_pair" "$g_tool_version" 'bins'
		local bin_dir=
		for bin_dir in "${REPLY[@]}"; do
			bin_dir=${bin_dir#./}
			local tool_dir="$install_dir/$bin_dir"

			new_path="$tool_dir${new_path:+":$new_path"}"
		done; unset -v bin_dir
	done
	unset -v

	printf '%s\n' '# --- path ----'
	printf '%s\n' "PATH=$new_path"
}

util.get_latest_tool_version() {
	unset -v REPLY; REPLY=
	local tool_pair="$1"
	local real_os="$2"
	local real_arch="$3"
	util.assert_not_empty 'tool_pair'
	util.assert_not_empty 'real_os'
	util.assert_not_empty 'real_arch'

	var.get_plugin_table_file "$g_tool_pair"
	local table_file="$REPLY"

	local variant= version= os= arch= url= comment=
	while IFS='|' read -r variant version os arch url comment; do
		if [ "$real_os" = "$os" ] && [ "$real_arch" = "$arch" ]; then
			REPLY="$version"
			break
		fi
	done < "$table_file"; unset -v version os arch url comment
}

util.determine_tool_pair() {
	local input="$1"
	local filter="$2"

	local tool_pair=
	local plugin_name=
	local tool_name=

	if [ -z "$input" ]; then
		util.plugin_get_plugins --filter="$filter" --with=name
		local -a all_plugins_arr=("${REPLY[@]}")
		local -A all_plugins_obj=()
		for m in "${all_plugins_arr[@]}"; do
			all_plugins_obj["$m"]=
		done; unset -v m
		tty.multiselect '' all_plugins_arr all_plugins_obj
		plugin_name="$REPLY"

		util.plugin_get_plugin_tools "$plugin_name" --filter="$filter"
		util.plugin_get_active_tools_of_plugin "$plugin_name"
		local all_tools_arr=("${REPLY[@]}")
		local -A all_tools_obj=()
		for m in "${all_tools_arr[@]}"; do
			all_tools_obj["$m"]=
		done; unset -v m
		tty.multiselect '' all_tools_arr all_tools_obj
		tool_name="$REPLY"

		tool_pair="$plugin_name/$tool_name"
	elif [[ "$input" != */* ]]; then
		# Input might be a tool, search for it in currently enabled plugins
		util.plugin_get_active_tools --with=pair
		local tools=("${REPLY[@]}")
		local tool=
		for tool in "${tools[@]}"; do
			if [ "$input" = "${tool#*/}" ]; then
				plugin_name=${tool%/*}
				tool_name=${tool#*/}

				tool_pair="$plugin_name/$tool_name"
				break
			fi
		done

		# Input might be a plugin, earch for currently enabled plugins
		if [ -z "$tool_pair" ]; then
			var.get_dir 'plugins'
			local plugins_dir="$REPLY"
			if [ -d "$plugins_dir/woof-plugin-$input" ]; then
				util.plugin_get_active_tools_of_plugin "$input"
				local all_tools_arr=("${REPLY[@]}")
				local -A all_tools_obj=()
				for m in "${all_tools_arr[@]}"; do
					all_tools_obj["$m"]=
				done; unset -v m
				tty.multiselect '' all_tools_arr all_tools_obj
				local _tool_name="$REPLY"

				plugin_name=$input
				tool_name="$_tool_name"

				tool_pair="$plugin_name/$tool_name"
			fi
		fi

		if [ -z "$tool_pair" ]; then
			util.print_error_die "Failed to find tool or plugin with name: $input"
		fi
	else
		plugin_name=${input%/*}
		tool_name=${input#*/}

		tool_pair=$input
	fi

	REPLY1=$tool_pair
	REPLY2=$plugin_name
	REPLY3=$tool_name
}
