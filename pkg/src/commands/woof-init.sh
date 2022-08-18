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
		printf "rm -rf \"${tty_dir}\";
mkdir -p \"$tty_dir\"
__woof_cleanup() { rm -rf \"$tty_dir\"; }
trap __woof_cleanup EXIT\n"
		printf '\n'
	fi

	# cd
	printf '%s\n' '# cd override'
	woof_override_cd
	printf '\n'

	# plugins
	printf '%s\n' '# plugins'
	# TODO: do not hard code these

	# deno
	var.get_dir 'installed-tools' 'deno'
	local install_dir="$REPLY"

	util.plugin_get_global_version 'deno'
	local version="$REPLY"

	std.shell_variable_assignment 'DENO_INSTALL_ROOT' "$install_dir/$version/files"
	std.shell_variable_export 'DENO_INSTALL_ROOT'
	std.shell_path_prepend "$DENO_INSTALL_ROOT/bin/bin"
	printf '\n'

	# go
	source "$BASALT_PACKAGE_DIR/pkg/src/plugins/go.sh"
	go.env
}

woof_override_cd() {
	case $shell in
	fish)
		cat<<-"EOF"
		function cd
		  woof tool cd-override
		  builtin cd "$@"
		end
		EOF
		;;
	zsh|ksh|bash|sh)
		cat<<-"EOF"
		cd() {
		  woof tool cd-override
		  builtin cd "$@"
		}
		EOF
		;;
	esac
}
