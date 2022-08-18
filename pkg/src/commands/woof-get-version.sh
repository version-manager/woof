# shellcheck shell=bash

woof-get-version() {
	local possible_plugin_name="$1"

	helper.determine_plugin_name "$possible_plugin_name"
	local plugin_name="$REPLY"
	unset -v possible_plugin_name

	util.get_current_plugin_version "$plugin_name"
	local version="$REPLY"

	printf '%s\n' "$REPLY"
}
