# shellcheck shell=bash

woof-plugin-info() {
	local plugin="$1"
	plugin=${plugin%/}

	local manifest_file=
	if util.plugin_is_absolute_path "$plugin"; then
		manifest_file="$plugin/manifest.ini"
	elif util.is_relative_path "$plugin"; then
		local dir=
		dir=$(realpath -f "$plugin")
		manifest_file="$dir/manifest.ini"
	fi

	util.plugin_parse_manifest "$manifest_file"
	local slug="$REPLY_SLUG"
	local name="$REPLY_NAME"
	local desc="$REPLY_DESC"
	local tags=("${REPLY_TAGS[@]}")

	printf '%s\n' "slug: $slug"
	printf '%s\n' "name: $name"
	printf '%s\n' "description: $desc"
	printf '%s' 'tags: '
	local i=
	for ((i=0; i<${#tags[@]}-1; ++i)); do
		printf '%s' "${tags[i]}, "
	done; unset -v i
	printf '%s\n' "${tags[-1]}"
}
