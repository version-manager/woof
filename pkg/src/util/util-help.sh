# shellcheck shell=bash

util.help_show() {
	printf '%s\n' "Usage:
   woof init <shell>
   woof [flags] <subcommand> [args...]

Flags:
    -h, --help
        Print help

    -q, --quiet
        Do not log informattive messages to stdout. Useful for scripting. Error messages will still be printed

Subcommands:
    init <shell>
        Print code for a particular shell to set the proper PATH, etc.

    install [--no-cache] [--force] [plugin] [version]
        Install a particular program

    uninstall [plugin] [version]
        Uninstall a particular program

    get-version [--global] [--full] [plugin]
        Get the current version of a program

    set-version [--global] [plugin] [version]
        Set the current version of a program

    list [--global] [--no-cache] [--all] [plugin]
        List programs
"
	util.help_show_plugin_core
	printf '%s\n' "
    tool <resymlink|info|print-dirs|cd-override|debug-table|debug-install|
        clear-table-cache> [args...]
            Run a particular tool Most of these are for internal use
"
}

util.help_show_plugin() {
	printf '%s\n' "Usage:
   woof plugin <subcommand> [args...]

Subcommands:"
	util.help_show_plugin_core
}

util.help_show_plugin_core() {
	printf '%s\n' "    plugin add [name]
        Add a plugin

    plugin remove [name]
        Remove a plugin

    plugin list
        List plugins"
}
