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

	# tty
	var.get_tty_dir --no-error
	local tty_dir="$REPLY"
	if [ -n "$tty_dir" ]; then
		printf '%s\n' '# local (per-tty) installs'
		std.shell_path_prepend "$tty_dir/bin"
		# shellcheck disable=SC2059
		printf "rm -rf \"${tty_dir}\"
mkdir -p \"$tty_dir\"
__woof_cleanup() { rm -rf \"$tty_dir\"; }
trap __woof_cleanup EXIT\n"
		printf '\n'
	fi

	# cd
	printf '%s\n' '# cd override'
	woof_override_cd "$flag_no_cd"
	printf '\n'

	# woof
	printf '%s\n' '# woof()'
	woof_function
	printf '\n'

	# TODO: do not hardcode
	printf '%s\n' '# --- plugins ----'
	local tool=
	for tool in nodejs deno go; do
		source "$BASALT_PACKAGE_DIR/pkg/src/tools/$tool.sh"

		printf '%s\n' "# $tool"
		"$tool".env
		printf '\n'
	done
}

woof_override_cd() {
	local flag_no_cd="$1"

	case $shell in
	# TODO flag_no_cd
	fish)
		cat <<-"EOF"
		function cd
		  woof tool cd-override
		  builtin cd "$@"
		end
		EOF
		;;
	zsh|ksh|bash|sh)
		printf '%s\n' '__woof_cd_hook() {
	woof tool cd-override
}'
	if [ "$flag_no_cd" = 'no' ]; then
		printf '%s\n' 'cd() {
	__woof_cd_hook
	builtin cd "$@"
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
