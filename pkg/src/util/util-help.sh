# shellcheck shell=bash

# root
util.help_show_cmd_root_all() {
	util.help_show_usage_and_flags '<command>'
	util.help_show_cmd_root 'init'
	util.help_show_cmd_root 'install'
	util.help_show_cmd_root 'uninstall'
	util.help_show_cmd_root 'get-version'
	util.help_show_cmd_root 'set-version'
	util.help_show_cmd_root 'exec'
	util.help_show_cmd_root 'list'
	util.help_show_cmd_root 'plugin'
	util.help_show_cmd_root 'tool'
}

util.help_show_cmd_root() {
	local subcmd="$1"

	case $subcmd in
	init)
		printf '\n    %s\n' "init [--no-cd] <shell>
        Print code for a particular shell to set the proper PATH, etc."
		;;
	install)
		printf '\n    %s\n' "install [--no-cache] [--force] [name] [version]
        Install a particular tool"
		;;
	uninstall)
		printf '\n    %s\n' "uninstall [plugin] [version]
        Uninstall a particular tool"
		;;
	get-version)
		printf '\n    %s\n' "get-version [--global] [--full] [plugin]
        Get the current version of a tool"
		;;
	set-version)
		printf '\n    %s\n' "set-version [--global] [plugin] [version]
        Set the current version of a tool"
		;;
	exec)
		printf '\n    %s\n' "exec <tool> <version> <executable>
        Execute the executable of a particular version of a tool"
		;;
	list)
		printf '\n    %s\n' "list [--global] [--no-cache] [--all] [plugin]
        List tools"
		;;
	plugin)
		printf '\n    %s\n' "plugin [...]
        Manage a plugin"
		;;
	tool)
		printf '\n    %s\n' "tool [...]
        Perform an internal command"
		;;
	*)
		util.print_fatal_die "Unrecognized argument: $1"
		;;
	esac
}

# plugin
util.help_show_cmd_plugin_all() {
	util.help_show_usage_and_flags 'plugin'
	util.help_show_cmd_plugin 'install'
	util.help_show_cmd_plugin 'uninstall'
	util.help_show_cmd_plugin 'enable'
	util.help_show_cmd_plugin 'disable'
	util.help_show_cmd_plugin 'info'
	util.help_show_cmd_plugin 'list'
}

util.help_show_cmd_plugin() {
	local subcmd="$1"

	case $subcmd in
	install)
		printf '\n    %s\n' "plugin install [--force] [name]
        Add a plugin"
		;;
	uninstall)
		printf '\n    %s\n' "plugin uninstall [name]
        Remove a plugin"
		;;
	enable)
		printf '\n    %s\n' "plugin enable [name]
        Enable a plugin"
		;;
	disable)
		printf '\n    %s\n' "plugin disable [name]
        Disable a plugin"
		;;
	info)
		printf '\n    %s\n' "plugin info [name]
        List information about a plugin"
		;;
	list)
		printf '\n    %s\n' "plugin list [--show-variants=web,local,builtin]
        List plugins"
		;;
	*)
		util.print_fatal_die "Unrecognized argument: $1"
	esac
}

# tool
util.help_show_cmd_tool_all() {
	printf '\n    %s\n' "tool <resymlink|print-dirs|cd-override|debug-table|debug-install|
            clear-table-cache|install-default-plugins> [args...]
        Run a particular tool. Most of these are for internal use"
}

# "helper" functions
util.help_show_usage_and_flags() {
	local subcmd="${1}"

	printf '%s\n\n' "Usage:
    woof [flags] $subcmd [--help] [args...]"

	printf '%s' "Flags:
    -h, --help
        Print help

    -q, --quiet
        Do not log informative messages to stdout. Error messages will still be printed

Subcommand(s):"
}

