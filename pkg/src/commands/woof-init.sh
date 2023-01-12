# shellcheck shell=bash

woof-init() {
	local -a subcmds=()
	local flag_no_cd='no'
	local arg=
	for arg; do case $arg in
	--no-cd)
		flag_no_cd='yes'
		;;
	-*)
		util.print_error_die "Flag '$arg' not recognized"
		;;
	*)
		subcmds+=("$arg")
		shift
	esac done; unset -v arg

	local shell="${subcmds[0]}"

	if [ -z "$shell" ]; then
		util.print_error_die 'Shell not specified'
	fi

	if [[ $shell != @(fish|zsh|ksh|bash|sh) ]]; then
		util.print_error_die 'Shell not supported'
	fi

	# global
	printf '%s\n' '# global installs'
	var.get_dir 'data-global' 'bin'
	std.shell_path_prepend "$REPLY"
	printf '\n'

	# cd
	printf '%s\n' '# cd override'
	woof_override_cd "$flag_no_cd"
	printf '\n'

	# woof
	printf '%s\n' '# woof()'
	woof_function
	printf '\n'

	printf '%s\n' '# --- plugins ----'
	# shellcheck disable=SC1007
	local plugin_path= tool=
	for plugin_path in "$BASALT_PACKAGE_DIR/pkg/src/plugins"/*/tools/*.sh; do
		# shellcheck disable=SC1090
		source "$plugin_path"
		tool=${plugin_path##*/}; tool=${tool%*.sh}

		if command -v "$tool".env &>/dev/null; then
			printf '%s\n' "# $tool"
			"$tool".env
			printf '\n'
		fi
	done
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
