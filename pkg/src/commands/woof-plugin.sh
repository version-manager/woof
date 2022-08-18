# shellcheck shell=bash

woof-plugin() {
	local arg=
	for arg; do case $arg in
	--help)
		util.help_show_plugin
		exit 0
		;;
	-*)
		core.print_die "Flag '$arg' not recognized"
		;;
	*)
		subcmds+=("$arg")
		shift
	esac done; unset -v arg

	local plugin_subcommands="$1"

	case $plugin_subcommands in
		add)
			woof-plugin-add "$@"
			;;
		remove)
			woof-plugin-remove "$@"
			;;
		list)
			woof-plugin-list "$@"
			;;
		*) core.print_die "Plugin subcommand '$plugin_subcommands' not recognized" ;;
	esac
}
