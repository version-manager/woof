# shellcheck shell=bash

woof-plugin-list() {
	var.get_dir 'installed-plugins'
	local plugins_dir="$REPLY"

	local has_plugin='no'

	core.shopt_push -s nullglob

	local dir=
	for dir in "$plugins_dir"/*/; do
		local plugin="${dir%/}"; plugin=${plugin##*/}

		if util.plugin_is_installed "$plugin"; then
			local type="$REPLY_TYPE"
			local dir="$REPLY_DIR"
			has_plugin='yes'

			# util.plugin_parse_manifest "$plugin_dir/manifest.ini"
			# local slug="$REPLY_SLUG"
			# local name="$REPLY_NAME"
			# local desc="$REPLY_DESC"
			# local tags=("${REPLY_TAGS[@]}")
			# printf '%s:\n  path: %s\n  type: %s\n' "$tool_name" "$plugin_dir" "$plugin_type"
			# TODO
			printf '%s\n  %s\n' "${plugin}:" "$type"
		fi
	done

	core.shopt_pop

	if [ "$has_plugin" = 'no' ]; then
		term.style_italic -Pd 'No items'
		return
	fi
}
