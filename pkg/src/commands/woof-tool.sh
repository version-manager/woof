# shellcheck shell=bash

woof-tool() {
	local subcmd="$1"
	if [ -z "$subcmd" ]; then
		util.help_show
		core.print_die 'Expected subcommand'
	fi
	if ! shift; then
		core.print_die 'Failed to shift'
	fi

	if [ "$subcmd" = 'resymlink' ]; then
		helper.resymlink_global_all
	elif [ "$subcmd" = 'info' ]; then
		local possible_plugin_name="$1"

		helper.determine_plugin_name "$possible_plugin_name"
		local plugin_name="$REPLY"
		unset -v possible_plugin_name

		var.get_dir 'data-global' 'selection'
		local global_selection_dir="$REPLY"

		printf '%s\n' '------ GLOBAL ------'
		if [ -f "$global_selection_dir/$plugin_name" ]; then
			printf '%s\n' "Version: $(<"$global_selection_dir/$plugin_name")"
		else
			printf '%s\n' "Version: (no global)"
		fi
		printf '\n'

		printf '%s\n' '------ DIRECTORY ------'
		m.toolversions_get_versions "$plugin_name"
		m.toolversions_get_first_valid_version "$plugin_name"
		printf '%s\n' "Version: ${version:-(no directory)}"

	elif [ "$subcmd" = 'print-dirs' ]; then
		local var_name=
		for var_name in $WOOF_VARS; do
			local -n var_value="$var_name"

			printf '%s\n' "---------- $var_name ----------"
			if [ -d "$var_value" ]; then
				tree -aL 2 --filelimit 15 --noreport "$var_value"
			else
				printf '\033[3m%s\033[0m\n' '  Does not exist'	# TODO: term-info
			fi
			printf '\n'
		done; unset -v var_name
		unset -vn var_value
	elif [ "$subcmd" = 'debug-table' ]; then
		local possible_plugin_name="$1"

		helper.determine_plugin_name "$possible_plugin_name"
		local plugin_name="$REPLY"
		unset -v possible_plugin_name

		util.run_function "$plugin_name.table"
	elif [ "$subcmd" = 'debug-install' ]; then
		local possible_plugin_name="$1"
		local possible_plugin_version="$2"

		helper.determine_plugin_name "$possible_plugin_name"
		local plugin_name="$REPLY"
		unset -v possible_plugin_name

		helper.create_version_table "$plugin_name"

		helper.determine_plugin_version "$plugin_name" "$possible_plugin_version"
		local plugin_version="$REPLY"
		unset -v possible_plugin_version

		helper.install_plugin_version 'yes' 'yes' "$plugin_name" "$plugin_version"
	elif [ "$subcmd" = 'clear-table-cache' ]; then
		local plugin_name="$1"

		var.get_plugin_table_file "$plugin_name"
		local table_file="$REPLY"

		if [ -z "$plugin_name" ]; then
			core.print_info "Removing all table cache"
			# Since '$plugin_name' is empty, the basename of '$table_file' is
			# not correct, but that doesn't matter as it is not used here
			rm -rf "${table_file%/*}"
		else
			core.print_info "Removing table cache for '$plugin_name'"
			rm -f "$table_file"
		fi
	elif [ "$subcmd" = 'cd-override' ]; then
		util.toolversions_get_path
		local toolversions_file="$REPLY"

		if [ -n "$toolversions_file" ]; then
			helper.toolversions_set_versions "$toolversions_file"
		fi
	else
		core.print_die "Subcommand '$subcmd' is not valid"
	fi
}
