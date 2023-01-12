# shellcheck shell=bash

woof-plugin-install() {
	local plugin="$1"
	local flag_force='no'
	local -a plugins=()
	local arg=
	for arg; do case $arg in
	--force)
		flag_force='yes'
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
