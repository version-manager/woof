# shellcheck shell=bash

woof-plugin-list() {
	util.plugin_prune

	var.get_dir 'installed-plugins'
	local plugins_dir="$REPLY"

	core.shopt_push -s nullglob
	local dir= plugin_{owner,name}=
	for dir in "$plugins_dir"/*/*/; do
		dir=${dir%/}
		plugin_name=${dir##*/}
		plugin_owner=${dir%/*}; plugin_owner=${plugin_owner##*/}

		printf '%s\n' "$plugin_owner/$plugin_name"
	done
	core.shopt_pop

	if [ "$has_plugin" = 'no' ]; then
		term.style_italic -Pd 'No items'
		return
	fi
}
