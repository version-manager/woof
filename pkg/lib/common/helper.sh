# shellcheck shell=bash

helper.fetch_or_getfrom_cached_version_file() {
	util.get_module_name
	local module_name="$REPLY"

	local fetch_url_variable="${module_name}_url"
	local -n fetch_command="$fetch_url_variable"

	
}
