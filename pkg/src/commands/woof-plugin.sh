# shellcheck shell=bash

woof-plugin() {
	local arg=
	for arg; do case $arg in
	--help)
		util.help_show_plugin
		exit 0
		;;
	-*)
		util.print_error_die "Flag '$arg' not recognized"
		;;
	*)
		break
	esac done; unset -v arg

	local subcommand="$1"
	if [ -z "$subcommand" ]; then
		util.help_show_plugin
		util.print_error_die 'No subcommand was given'
	fi
	if ! shift; then
		util.print_fatal_die 'Failed to shift'
	fi
	case $subcommand in
		install)
			woof-plugin-install "$@"
			;;
		uninstall)
			woof-plugin-uninstall "$@"
			;;
		enable)
			woof-plugin-enable "$@"
			;;
		disable)
			woof-plugin-disable "$@"
			;;
		info)
			woof-plugin-info "$@"
			;;
		list)
			woof-plugin-list "$@"
			;;
		*) util.print_error_die "Plugin subcommand '$subcommand' not recognized" ;;
	esac
}
