# shellcheck shell=bash

woof-init() {
	local -a args=()
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
		args+=("$arg")
	esac done; unset -v arg

	local shell="${args[0]}"

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

	util.path_things
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
		# shellcheck disable=SC2016
		printf '%s\n' '__woof_cd_hook() {
	eval "$(woof tool cd-override)"
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
	builtin eval \"\$(builtin command woof tool print-eval)\"
	builtin hash -r
}"
}
