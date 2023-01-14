# shellcheck shell=bash

woof-plugin-info() {
	local -a subcmds=()
	local arg=
	for arg; do case $arg in
	--help)
		util.help_show_usage_and_flags 'plugin info'
		util.help_show_cmd_plugin 'info'
		exit 0
		;;
	-*)
		util.print_error_die "Flag '$arg' not recognized"
		;;
	*)
		subcmds+=("$arg")
	esac done; unset -v arg

	local plugin="${subcmds[0]}"

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
