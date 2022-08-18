# shellcheck shell=bash

woof-tool() {
	local subcmd="$1"
	if [ -z "$subcmd" ]; then
		util.show_help
		core.print_die 'Expected subcommand'
	fi
	if ! shift; then
		core.print_die 'Failed to shift'
	fi

	if [ "$subcmd" = 'resymlink' ]; then
		local possible_module_name="$1"
		local possible_module_version="$2"

		helper.determine_module_name "$possible_module_name"
		local module_name="$REPLY"
		unset -v possible_module_name

		helper.create_version_table "$module_name"

		helper.determine_module_version "$module_name" "$possible_module_version"
		local module_version="$REPLY"
		unset -v possible_module_version

		helper.symlink_after_install "$module_name" "$module_version"
	elif [ "$subcmd" = 'info' ]; then
		local possible_module_name="$1"

		helper.determine_module_name "$possible_module_name"
		local module_name="$REPLY"
		unset -v possible_module_name

		var.get_dir 'global' 'selection'
		local global_selection_dir="$REPLY"

		printf '%s\n' '------ GLOBAL ------'
		if [ -f "$global_selection_dir/$module_name" ]; then
			printf '%s\n' "Version: $(<"$global_selection_dir/$module_name")"
		else
			printf '%s\n' "Version: (no global)"
		fi
		printf '\n'

		printf '%s\n' '------ DIRECTORY ------'
		m.toolversions_get_versions "$module_name"
		m.toolversions_get_first_valid_version "$module_name"
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
		local possible_module_name="$1"

		helper.determine_module_name "$possible_module_name"
		local module_name="$REPLY"
		unset -v possible_module_name

		util.run_function "$module_name.table"
	elif [ "$subcmd" = 'debug-install' ]; then
		local possible_module_name="$1"
		local possible_module_version="$2"

		helper.determine_module_name "$possible_module_name"
		local module_name="$REPLY"
		unset -v possible_module_name

		helper.create_version_table "$module_name"

		helper.determine_module_version "$module_name" "$possible_module_version"
		local module_version="$REPLY"
		unset -v possible_module_version

		helper.install_module_version --interactive "$module_name" "$module_version"
	elif [ "$subcmd" = 'clear-table-cache' ]; then
		local module_name="$1"

		var.get_module_table_file "$module_name"
		local table_file="$REPLY"

		if [ -z "$module_name" ]; then
			core.print_info "Removing all table cache"
			# Since '$module_name' is empty, the basename of '$table_file' is
			# not correct, but that doesn't matter as it is not used here
			rm -rf "${table_file%/*}"
		else
			core.print_info "Removing table cache for '$module_name'"
			rm -f "$table_file"
		fi
	elif [ "$subcmd" = 'cd-override' ]; then
		printf '%s\n' 'cd override'
		helper.toolversions_set_versions_in_accordance
	else
		core.print_die "Subcommand '$subcmd' is not valid"
	fi
}
