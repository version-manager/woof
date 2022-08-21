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

	# woof
	printf '%s\n' '# woof()'
	woof_function
	printf '\n'

	# plugins
	printf '%s\n' '# plugins'
	# TODO: do not hard code these

	# deno
	var.get_dir 'installed-tools' 'deno'
	local install_dir="$REPLY"

	util.tool_get_global_version 'deno'
	local tool_version_global="$REPLY"

	std.shell_variable_assignment 'DENO_INSTALL_ROOT' "$install_dir/$tool_version_global/files"
	std.shell_variable_export 'DENO_INSTALL_ROOT'
	std.shell_path_prepend "$DENO_INSTALL_ROOT/bin/bin"
	printf '\n'

	# pnpm
	printf '%s\n' '# pnpm'
	std.shell_variable_assignment 'PNPM_HOME' "${XDG_DATA_HOME:-$HOME/.local/share}/pnpm"
	std.shell_variable_export 'PNPM_HOME'
	std.shell_path_prepend '$PNPM_HOME'
	printf '\n'

	# deno
	printf '%s\n' '# deno'
	std.shell_variable_assignment 'DENO_INSTALL' "${XDG_STATE_HOME:-$HOME/.local/state}/deno"
	std.shell_variable_export 'DENO_INSTALL'
	std.shell_path_prepend '$DENO_INSTALL'
	printf '\n'

	# go
	printf '%s\n' '# go'
	source "$BASALT_PACKAGE_DIR/pkg/src/plugins/go.sh"
	go.env
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
