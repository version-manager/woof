# shellcheck shell=bash

woof-plugin-info() {
	local plugin="$1"

	if [ -z "$plugin" ]; then
		util.print_error_die "Passed plugin cannot be empty"
	fi

	util.plugin_resolve_internal_path "$plugin"
	local plugin_src="$REPLY"
	local manifest_file="$plugin_src/manifest.ini"

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
