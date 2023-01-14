# shellcheck shell=bash

woof-plugin-install() {
	local -a plugins=()
	local flag_force='no'
	local arg=
	for arg; do case $arg in
	--help)
		util.help_show_usage_and_flags 'plugin install'
		util.help_show_cmd_plugin 'install'
		exit 0
		;;
	--force)
		flag_force='yes'
		;;
	-*)
		util.print_error_die "Flag '$arg' not recognized"
		;;
	*)
		plugins+=("$arg")
	esac done; unset -v arg

	local plugin="${plugins[0]}"

	if [ -z "$plugin" ]; then
		util.print_error_die "Passed plugin cannot be empty"
	fi

	util.plugin_prune

	util.plugin_resolve_external_path "$plugin"
	local plugin_type="$REPLY_TYPE"
	local plugin_src="$REPLY_SRC"
	local plugin_target="$REPLY_TARGET"

	util.plugin_install "$plugin_type" "$plugin_src" "$plugin_target" "$flag_force"
}
