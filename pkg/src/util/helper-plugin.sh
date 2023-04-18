# shellcheck shell=bash

# @description Enable all the plugins that come with Woof
helper.plugin_enable_all_builtins() {
	util.plugin_get_builtin_plugin_list
	local builtin_plugins=("${REPLY[@]}")

	local plugin_src=
	for plugin_src in "${builtin_plugins[@]}"; do
		local plugin_slug="${plugin_src##*/}"

		var.get_dir 'plugins'
		local plugin_target="$REPLY/$plugin_slug"
		local flag_force='yes'
		util.plugin_install 'symlink' "$plugin_src" "$plugin_target" "$flag_force"

		# TODO: Remove this validation (costly for performance, this runs on init)
		util.plugin_assert_is_valid "$plugin_src"
	done; unset -v plugin_src
}
