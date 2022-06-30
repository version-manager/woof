# shellcheck shell=bash

woof-init() {
	local shell="$1"

	if [ -z "$shell" ]; then
		core.print_die 'Shell not specified'
	fi

	if [[ $shell != @(fish|zsh|ksh|bash|sh) ]]; then
		core.print_die 'Shell not supported'
	fi

	var.get_dir 'global' 'bin'
	std.shell_path_prepend "$REPLY"
	

	var.get_module_install_dir 'deno'
	local install_dir="$REPLY"

	util.get_current_module_version 'deno'
	local version="$REPLY"

	std.shell_variable_assignment 'DENO_INSTALL_ROOT' "$install_dir/$version/files"
	std.shell_variable_export 'DENO_INSTALL_ROOT'
	std.shell_path_prepend "$DENO_INSTALL_ROOT/bin/bin"

	woof_override_cd
	source "$BASALT_PACKAGE_DIR/pkg/src/modules/go.sh"
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