# shellcheck shell=bash

woof-plugin() {
	local arg=
	for arg; do case $arg in
	--help)
		util.help_show_cmd_plugin_all
		if ! shift; then
			util.print_fatal_die 'Failed to shift'
		fi
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
		util.help_show_cmd_plugin_all
		util.print_error_die 'No subcommand was given'
	fi
	if ! shift; then
		util.print_fatal_die 'Failed to shift'
	fi
	# shellcheck disable=SC1090
	case $subcommand in
		install)
			source "$BASALT_PACKAGE_DIR/pkg/src/commands/woof-plugin-$subcommand.sh"
			woof-plugin-install "$@"
			;;
		uninstall)
			source "$BASALT_PACKAGE_DIR/pkg/src/commands/woof-plugin-$subcommand.sh"
			woof-plugin-uninstall "$@"
			;;
		enable)
			source "$BASALT_PACKAGE_DIR/pkg/src/commands/woof-plugin-$subcommand.sh"
			woof-plugin-enable "$@"
			;;
		disable)
			source "$BASALT_PACKAGE_DIR/pkg/src/commands/woof-plugin-$subcommand.sh"
			woof-plugin-disable "$@"
			;;
		info)
			source "$BASALT_PACKAGE_DIR/pkg/src/commands/woof-plugin-$subcommand.sh"
			woof-plugin-info "$@"
			;;
		list)
			source "$BASALT_PACKAGE_DIR/pkg/src/commands/woof-plugin-$subcommand.sh"
			woof-plugin-list "$@"
			;;
		*) util.print_error_die "Plugin subcommand '$subcommand' not recognized" ;;
	esac
}
