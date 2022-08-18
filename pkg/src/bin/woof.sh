# shellcheck shell=bash

main.woof() {
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
			core.print_die "Failed to read from file '$token_file'"
		fi
		export GITHUB_TOKEN
	else
		core.print_die "Must have a file containing your GitHub token at '$token_file'"
	fi
	unset -v token_file

	local arg=
	for arg; do case "$arg" in
	--help|-h)
		util.help_show
		exit
		;;
	-*)
		core.print_die "Flag '$arg' not recognized"
		;;
	*)
		break
		;;
	esac done; unset -v arg

	# Get action name
	local subcommand="$1"
	if [ -z "$subcommand" ]; then
		util.help_show
		core.print_die 'No subcommand was given'
	fi
	if ! shift; then
		core.print_die 'Failed to shift'
	fi

	case $subcommand in
		init) woof-init "$@";;
		install) woof-install "$@" ;;
		uninstall) woof-uninstall "$@" ;;
		get-version) woof-get-version "$@" ;;
		set-version) woof-set-version "$@" ;;
		list) woof-list "$@" ;;
		plugin) woof-plugin "$@" ;;
		tool) woof-tool "$@" ;;
		*) core.print_die "Subcommand '$subcommand' not recognized" ;;
	esac
}
