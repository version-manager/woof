# shellcheck shell=bash

main.woof() {
	global_trap_err() {
		core.print_stacktrace
	}
	core.trap_add 'global_trap_err' 'ERR'

	global_stty_saved=
	global_tty_height=
	global_tty_width=

	: "${WOOF_CONFIG_HOME:=${XDG_CONFIG_HOME:-$HOME/.config}/woof}"
	: "${WOOF_CACHE_HOME:=${XDG_CACHE_HOME:-$HOME/.cache}/woof}"
	: "${WOOF_DATA_HOME:=${XDG_DATA_HOME:-$HOME/.local/share}/woof}"
	: "${WOOF_STATE_HOME:=${XDG_STATE_HOME:-$HOME/.local/state}/woof}"
	WOOF_VARS='WOOF_CONFIG_HOME WOOF_CACHE_HOME WOOF_DATA_HOME WOOF_STATE_HOME'

	local token_file="$WOOF_DATA_HOME/token"
	if [ -f "$token_file" ]; then
		if ! GITHUB_TOKEN=$(<"$token_file"); then
			util.print_error_die "Failed to read from file '$token_file'"
		fi
		export GITHUB_TOKEN
	else
		util.print_error_die "Must have a file containing your GitHub token at '$token_file'"
	fi
	unset -v token_file

	helper.plugin_enable_all_builtins

	local global_flag_quiet='no'
	local arg=
	for arg; do case $arg in
	--help|-h)
		util.help_show_cmd_root_all
		exit
		;;
	--quiet|-q)
		global_flag_quiet='yes'
		if ! shift; then
			util.print_fatal_die 'Failed to shift'
		fi
		;;
	-*)
		util.print_error_die "Global flag '$arg' not recognized"
		;;
	*)
		break
		;;
	esac done; unset -v arg

	# Get action name
	local subcommand="$1"
	if [ -z "$subcommand" ]; then
		util.help_show_cmd_root_all
		util.print_error_die 'No subcommand was given'
	fi
	if ! shift; then
		util.print_fatal_die 'Failed to shift'
	fi

	# shellcheck disable=SC1090
	case $subcommand in
		init)
			source "$BASALT_PACKAGE_DIR/pkg/src/commands/woof-$subcommand.sh"
			woof-init "$@"
			;;
		install)
			source "$BASALT_PACKAGE_DIR/pkg/src/commands/woof-$subcommand.sh"
			woof-install "$@"
			;;
		uninstall)
			source "$BASALT_PACKAGE_DIR/pkg/src/commands/woof-$subcommand.sh"
			woof-uninstall "$@"
			;;
		get-version)
			source "$BASALT_PACKAGE_DIR/pkg/src/commands/woof-$subcommand.sh"
			woof-get-version "$@"
			;;
		set-version)
			source "$BASALT_PACKAGE_DIR/pkg/src/commands/woof-$subcommand.sh"
			woof-set-version "$@"
			;;
		exec)
			source "$BASALT_PACKAGE_DIR/pkg/src/commands/woof-$subcommand.sh"
			woof-exec "$@"
			;;
		list)
			source "$BASALT_PACKAGE_DIR/pkg/src/commands/woof-$subcommand.sh"
			woof-list "$@"
			;;
		plugin)
			source "$BASALT_PACKAGE_DIR/pkg/src/commands/woof-$subcommand.sh"
			woof-plugin "$@"
			;;
		tool)
			source "$BASALT_PACKAGE_DIR/pkg/src/commands/woof-$subcommand.sh"
			woof-tool "$@"
			;;
		*) util.print_error_die "Subcommand '$subcommand' not recognized" ;;
	esac
}
