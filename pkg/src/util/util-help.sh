# shellcheck shell=bash

util.help_show_part() {
	local subcmd="$1"

	case $subcmd in
	.init)
		printf '\n    %s\n' "init [--no-cd] <shell>
        Print code for a particular shell to set the proper PATH, etc."
		;;
	.install)
		printf '\n    %s\n' "install [--no-cache] [--force] [name] [version]
        Install a particular tool"
		;;
	.uninstall)
		printf '\n    %s\n' "uninstall [plugin] [version]
        Uninstall a particular tool"
		;;
	.get-version)
		printf '\n    %s\n' "get-version [--global] [--full] [plugin]
        Get the current version of a tool"
		;;
	.set-version)
		printf '\n    %s\n' "set-version [--global] [plugin] [version]
        Set the current version of a tool"
		;;
	.exec)
		printf '\n    %s\n' "exec <tool> <version> <executable>
        Execute the executable of a particular version of a tool"
		;;
	.list)
		printf '\n    %s\n' "list [--global] [--no-cache] [--all] [plugin]
        List tools"
		;;
	.plugin)
		printf '\n    %s\n' "plugin [...]
        Manage a plugin"
		;;
	.plugin.install)
		printf '\n    %s\n' "plugin install [--force] [name]
        Add a plugin"
		;;
	.plugin.uninstall)
		printf '\n    %s\n' "plugin uninstall [name]
        Remove a plugin"
		;;
	.plugin.enable)
		printf '\n    %s\n' "plugin enable [name]
        Enable a plugin"
		;;
	.plugin.disable)
		printf '\n    %s\n' "plugin disable [name]
        Disable a plugin"
		;;
	.plugin.info)
		printf '\n    %s\n' "plugin info [name]
        Show information about a plugin"
		;;
	.plugin.list)
		printf '\n    %s\n' "plugin list [plugin]
        List plugins"
		;;
	.tool)
		printf '\n    %s\n' "tool [...]
        Run an internal command"
		;;
	*)
		util.print_fatal_die "Unrecognized help command: $1"
	esac
}

# root
util.help_show_cmd_root_all() {
	util.help_show_usage_and_flags '<command>'
	util.help_show_part '.init'
	util.help_show_part '.install'
	util.help_show_part '.uninstall'
	util.help_show_part '.get-version'
	util.help_show_part '.set-version'
	util.help_show_part '.exec'
	util.help_show_part '.list'
	util.help_show_part '.plugin'
	util.help_show_part '.tool'
}

# plugin
util.help_show_cmd_plugin_all() {
	util.help_show_usage_and_flags 'plugin'
	util.help_show_part '.plugin.install'
	util.help_show_part '.plugin.uninstall'
	util.help_show_part '.plugin.enable'
	util.help_show_part '.plugin.disable'
	util.help_show_part '.plugin.info'
	util.help_show_part '.plugin.list'
}

# tool
util.help_show_cmd_tool_all() {
	printf '\n    %s\n' "tool <get-exe|print-dirs|cd-override|debug-table|debug-install|
            clear-table-cache|install-default-plugins> [args...]
        Run a particular tool. Most of these are for internal use"
}

# "helper" functions
util.help_show_usage_and_flags() {
	local subcmd="$1"
	subcmd=${subcmd#.}
	subcmd=${subcmd//./ }

	printf '%s\n\n' "Usage:
    woof [flags] $subcmd [args...] [--help]"

	printf '%s' "Flags:
    -h, --help
        Print help

    -q, --quiet
        Do not log informative messages to stdout. Error messages will still be printed

Subcommand(s):"
}

