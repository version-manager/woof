# shellcheck shell=bash

woof-init() {
	local -a subcmds=()
	local flag_no_cd='no'
	local arg=
	for arg; do case $arg in
	--help)
		util.help_show_usage_and_flags 'init'
		util.help_show_part '.init'
		exit 0
		;;
	--no-cd)
		flag_no_cd='yes'
		;;
	-*)
		util.print_help_die '.init' "Flag '$arg' not recognized"
		;;
	*)
		subcmds+=("$arg")
	esac done; unset -v arg

	local shell="${subcmds[0]}"

	if [ -z "$shell" ]; then
		util.print_error_die 'Shell not specified'
	fi

	if [[ $shell != @(fish|zsh|ksh|bash|sh) ]]; then
		util.print_error_die 'Shell not supported'
	fi

	# woof
	printf '%s\n' '# woof()'
	woof_function
	printf '\n'

	# cd
	printf '%s\n' '# cd override'
	woof_override_cd "$flag_no_cd"
	printf '\n'

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

	# TODO
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
	for file in ~/.local/state/woof/data/selection/*/*; do
		declare -g g_plugin_name=${file%/*}; g_plugin_name=${g_plugin_name##*/}
		declare -g g_tool_name=${file##*/}
		declare -g g_tool_version=
		g_tool_version=$(<"$file")
		declare -g g_tool_pair=$g_plugin_name/$g_tool_name

		# local install_dir="$HOME/.local/state/woof/tools/$g_tool_name/$g_tool_name/$g_tool_version"
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

	printf '%s\n' '# --- path ----'
	printf '%s\n' "PATH=$new_path"

}

woof_override_cd() {
	local flag_no_cd="$1"

	case $shell in
	fish)
		printf '%s\n' 'function __woof_cd_hook()
	woof tool cd-override
end'
	if [ "$flag_no_cd" = 'no' ]; then
		printf '%s\n' 'function cd
	__woof_cd_hook
	builtin cd "$@"
end
function pushd
	__woof_cd_hook
	builtin pushd "$@"
end
function popd
	__woof_cd_hook
	builtin popd "$@"
end'
	fi
		;;
	zsh|ksh|bash|sh)
		printf '%s\n' '__woof_cd_hook() {
	woof tool cd-override
}'
	if [ "$flag_no_cd" = 'no' ]; then
		printf '%s\n' 'cd() {
	__woof_cd_hook
	builtin cd "$@"
}
pushd() {
	__woof_cd_hook
	builtin pushd "$@"
}
popd() {
	__woof_cd_hook
	builtin popd "$@"
}'
	fi
		;;
	esac
}

woof_function() {
	printf '%s\n' "woof() {
	builtin command woof \"\$@\"
	builtin hash -r
}"
}
