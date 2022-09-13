# shellcheck shell=bash

woof-plugin-install() {
	local plugin="$1"

	if [ -z "$plugin" ]; then
		util.print_error_die "Passed plugin cannot be empty"
	fi

	util.plugin_prune

	util.plugin_resolve_path "$plugin"
	local plugin_type="$REPLY_TYPE"
	local plugin_src="$REPLY_SRC"
	local plugin_target="$REPLY_TARGET"

	util.plugin_assert_is_valid "$plugin_type" "$plugin_src"
	util.plugin_install "$plugin_type" "$plugin_src" "$plugin_target"
}
