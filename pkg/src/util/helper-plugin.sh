# shellcheck shell=bash

# @description Enable all the plugins that come with Woof
helper.plugin_enable_all_builtins() {
	var.get_dir 'installed-plugins'
	local plugins_dir="$REPLY"

	util.plugin_get_builtin_plugin_list
	local builtin_plugins=("${REPLY[@]}")

	local dir=
	for dir in "${builtin_plugins[@]}"; do
		local plugin_slug="${dir##*/}"

		local plugin_src="$dir"
		local plugin_target="$plugins_dir/builtin-$plugin_slug"
		local flag_force='yes'
		util.plugin_install 'symlink' "$plugin_src" "$plugin_target" "$flag_force"

		# TODO: Remove this validation (costly for performance, this runs on init)
		util.plugin_assert_is_valid 'symlink' "$dir"
	done; unset -v dir
}
