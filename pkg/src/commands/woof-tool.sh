# shellcheck shell=bash

woof-tool() {
	local subcmd="$1"
	if [ -z "$subcmd" ]; then
		util.help_show
		util.print_error_die 'Expected subcommand'
	fi
	if ! shift; then
		util.print_fatal_die 'Failed to shift'
	fi

	if [ "$subcmd" = 'resymlink' ]; then
		helper.resymlink_global_all
	elif [ "$subcmd" = 'print-dirs' ]; then
		local var_name=
		for var_name in $WOOF_VARS; do
			local -n var_value="$var_name"

			printf '%s\n' "---------- $var_name ----------"
			if [ -d "$var_value" ]; then
				tree -aL 2 --filelimit 15 --noreport "$var_value"
			else
				term.style_italic -Pd 'Does not exist'
			fi
			printf '\n'
		done; unset -v var_name
		unset -vn var_value
	elif [ "$subcmd" = 'debug-table' ]; then
		local possible_tool_name="$1"

		helper.determine_tool_name "$possible_tool_name"
		local tool_name="$REPLY"
		unset -v possible_tool_name

		util.run_function "$tool_name.table"
	elif [ "$subcmd" = 'debug-install' ]; then
		local possible_tool_name="$1"
		local possible_tool_version="$2"

		helper.determine_tool_name "$possible_tool_name"
		local tool_name="$REPLY"
		unset -v possible_tool_name

		helper.create_version_table "$tool_name"

		helper.determine_tool_version "$tool_name" "$possible_tool_version"
		local tool_version="$REPLY"
		unset -v possible_tool_version

		helper.install_tool_version 'yes' 'yes' "$tool_name" "$tool_version"
	elif [ "$subcmd" = 'clear-table-cache' ]; then
		local tool_name="$1"

		var.get_plugin_table_file "$tool_name"
		local table_file="$REPLY"

		if [ -z "$tool_name" ]; then
			util.print_info "Removing all table cache"
			# Since '$tool_name' is empty, the basename of '$table_file' is
			# not correct, but that doesn't matter as it is not used here
			rm -rf "${table_file%/*}"
		else
			util.print_info "Removing table cache for '$tool_name'"
			rm -f "$table_file"
		fi
	elif [ "$subcmd" = 'cd-override' ]; then
		util.toolversions_get_path
		local toolversions_file="$REPLY"

		if [ -n "$toolversions_file" ]; then
			helper.toolversions_set_versions "$toolversions_file"
		fi
	else
		util.print_error_die "Subcommand '$subcmd' is not valid"
	fi
}
