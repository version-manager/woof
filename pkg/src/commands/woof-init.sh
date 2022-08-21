# shellcheck shell=bash

woof-init() {
	local shell="$1"

	if [ -z "$shell" ]; then
		core.print_die 'Shell not specified'
	fi

	if [[ $shell != @(fish|zsh|ksh|bash|sh) ]]; then
		core.print_die 'Shell not supported'
	fi

	# global
	printf '%s\n' '# global installs'
	var.get_dir 'data-global' 'bin'
	std.shell_path_prepend "$REPLY"
	printf '\n'

	# tty
	if var.get_tty_dir; then
		local tty_dir="$REPLY"

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
	woof_override_cd
	printf '\n'

	# woof
	printf '%s\n' '# woof()'
	woof_function
	printf '\n'

	# TODO: do not hardcode
	printf '%s\n' '# --- plugins ----'
	local tool=
	for tool in nodejs deno go; do
		source "$BASALT_PACKAGE_DIR/pkg/src/plugins/$tool.sh"

		printf '%s\n' "# $tool"
		"$tool".env
		printf '\n'
	done
}

woof_override_cd() {
	case $shell in
	fish)
		cat <<-"EOF"
		function cd
		  woof tool cd-override
		  builtin cd "$@"
		end
		EOF
		;;
	zsh|ksh|bash|sh)
		cat <<-"EOF"
		cd() {
		  woof tool cd-override
		  builtin cd "$@"
		}
		EOF
		;;
	esac
}

woof_function() {
	printf '%s\n' "woof() {
	if __woof_location=\$(type -P woof); then
		\"\$__woof_location\" \"\$@\"
		builtin hash -r
	else
		printf '%s\n' \"Error: Failed to find 'woof' executable\" >&2
	fi
}"
}
