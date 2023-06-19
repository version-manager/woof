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
		printf '\n    %s\n' "plugin install [--force] [name...]
        Add a plugin"
		;;
	.plugin.uninstall)
		printf '\n    %s\n' "plugin uninstall [name...]
        Remove a plugin"
		;;
	.plugin.enable)
		printf '\n    %s\n' "plugin enable [name...]
        Enable a plugin"
		;;
	.plugin.disable)
		printf '\n    %s\n' "plugin disable [name...]
        Disable a plugin"
		;;
	.plugin.info)
		printf '\n    %s\n' "plugin info [name...]
        Show information about a plugin"
		;;
	.plugin.list)
		printf '\n    %s\n' "plugin list
        List plugins"
		;;
	.tool)
		printf '\n    %s\n' "tool [...]
        Run an internal command"
		;;
	.tool.get-exe)
		printf '\n    %s\n' "tool get-exe
        Get the executable of a plugin's tool"
		;;
	.tool.print-dirs)
		printf '\n    %s\n' "tool print-dirs
        Print some directories"
		;;
	.tool.debug-table)
		printf '\n    %s\n' "tool debug-table
        Run the table() function of a plugin's tool"
		;;
	.tool.debug-install)
		printf '\n    %s\n' "tool debug-install
        Run the install() function of a plugin's tool"
		;;
	.tool.clear-table-cache)
		printf '\n    %s\n' "tool debug-install
        Clear the table cache"
		;;
	.tool.cd-override)
		printf '\n    %s\n' "tool debug-install
        Override the cd builtin"
		;;
	*)
		util.print_fatal_die "Unrecognized help command: $1"
	esac
}

# root
util.help_show_cmd_root_all() {
	util.help_show_usage_and_flags '<subcommand>'
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
	util.help_show_usage_and_flags 'plugin <subcommand>'
	util.help_show_part '.plugin.install'
	util.help_show_part '.plugin.uninstall'
	util.help_show_part '.plugin.enable'
	util.help_show_part '.plugin.disable'
	util.help_show_part '.plugin.info'
	util.help_show_part '.plugin.list'
}

# tool
util.help_show_cmd_tool_all() {
	util.help_show_usage_and_flags 'tool <subcommand>'
	util.help_show_part '.tool.get-exe'
	util.help_show_part '.tool.print-dirs'
	util.help_show_part '.tool.debug-table'
	util.help_show_part '.tool.debug-install'
	util.help_show_part '.tool.clear-table-cache'
	util.help_show_part '.tool.cd-override'
}

# "helper" functions
util.help_show_usage_and_flags() {
	local subcmd="$1"
	subcmd=${subcmd#.}
	subcmd=${subcmd//./ }

	printf '%s\n\n' "Usage:
    woof [flags] $subcmd [args...]"

	printf '%s' "Flags:
    -h, --help
        Print help

    -q, --quiet
        Do not log informative messages to stdout. Error messages will still be printed

Subcommand(s):"
}

