# shellcheck shell=bash

main.woof() {
	core.init
	global_stty_saved=
	global_tty_height=
	global_tty_width=

	: "${WOOF_CONFIG_HOME:=${XDG_CONFIG_HOME:-$HOME/.config}/woof}"
	: "${WOOF_CACHE_HOME:=${XDG_CACHE_HOME:-$HOME/.cache}/woof}"
	: "${WOOF_DATA_HOME:=${XDG_DATA_HOME:-$HOME/.local/share}/woof}"
	: "${WOOF_STATE_HOME:=${XDG_STATE_HOME:-$HOME/.local/state}/woof}"
	
	if [ -f "$WOOF_DATA_HOME/token" ]; then
		if ! GITHUB_TOKEN=$(<"$WOOF_DATA_HOME/token"); then
			print.die "Failed to read token file"
		fi
		export GITHUB_TOKEN
	fi

	local arg=
	for arg; do case "$arg" in
	--help|-h)
		util.show_help
		exit
		;;
	-*)
		print.die "Flag '$arg' not recognized"
		;;
	*)
		break
		;;
	esac done; unset -v arg

	# Get action name
	local action_name="$1"
	if [ -z "$action_name" ]; then
		util.show_help
		print.die 'No action was given'
	fi
	if ! shift; then
		print.die 'Failed to shift'
	fi

	case $action_name in
		init) woof-init "$@";;
		install) woof-install "$@" ;;
		uninstall) woof-uninstall "$@" ;;
		get-version) woof-get-version "$@" ;;
		set-version) woof-set-version "$@" ;;
		list) woof-list "$@" ;;
		tool) woof-tool "$@" ;;
		*) print.die "Subcommand '$action_name' not recognized" ;;
	esac
}
