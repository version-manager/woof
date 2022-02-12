# shellcheck shell=bash

# Credit to yoctu for this
trap_err() {
	local err=$?
	if [ "$err" -eq 0 ]; then
		return
	fi

	printf '%s\n' "Error in ${BASH_SOURCE[1]}:${BASH_LINENO[0]}. '${BASH_COMMAND}' exited with status $err"

	printf '%s\n' "Call stack:"
	for ((i=1;i<${#FUNCNAME[@]}-1;i++)); do
		printf '%s\n' " $i: ${BASH_SOURCE[$i+1]}:${BASH_LINENO[$i]} ${FUNCNAME[$i]}(...)"
	done

	printf '%s\n' "Exiting with status ${err}"
	exit $err
}

main.woof() {
	core.init

	trap trap_err ERR EXIT # TODO

	global_stty_saved=
	global_tty_height=
	global_tty_width=

	WOOF_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/woof"
	WOOF_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/woof"
	WOOF_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}/woof"

	local subcmds=()
	for arg; do case "$arg" in
		--help|-h)
			util.show_help
			exit
			;;
		-*)
			print.die "Flag '$arg' not recognized"
			;;
		*)
			subcmds+=("$arg")
			;;
	esac done; unset arg

	# Get action name
	local action_name="${subcmds[0]}"
	if [ -z "$action_name" ]; then
		util.show_help
		print.die "No action was given"
	fi
	subcmds=("${subcmds[@]:1:${#subcmds[@]}}")

	case "$action_name" in
	init)
		woof-init
		;;
	install)
		woof-install "${subcmds[@]}"
		;;
	uninstall)
		woof-uninstall "${subcmds[@]}"
		;;
	get-version)
		print.die 'Not implemented'
		;;
	set-version)
		print.die 'Not implemented'
		;;
	debug)
		woof-debug "${subcmds[@]}"
		;;
	list)
		woof-list "${subcmds[@]}"
		;;
	set-global)
		woof-set-global "${subcmds[@]}"
		;;
	*)
		print.die "Subcommand '$action_name' not recognized"
		;;
	esac
}
