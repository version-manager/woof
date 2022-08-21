# shellcheck shell=bash

woof-plugin-list() {
	var.get_dir 'common'
	local plugin_list_file="$REPLY/plugin-list.txt"

	if [ ! -f "$plugin_list_file" ]; then
		term.style_italic -Pd 'No items'
		return
	fi

	local has_plugin='no'
	local plugin_{type,place}=
	while IFS='|' read -r plugin_type plugin_place; do
		has_plugin='yes'

		term.underline -d "${plugin_place##*/}"
		local tool_name="$REPLY"

		printf '%s\n  path: %s\n  type: %s\n' "$tool_name" "$plugin_place" "$plugin_type"
	done < "$plugin_list_file"; unset -v line

	if [ "$has_plugin" = 'no' ]; then
		term.style_italic -Pd 'No items'
		return
	fi
}
