# shellcheck shell=bash

woof-tool() {
	local -a subcmds=()
	local arg=
	for arg; do case $arg in
	# --help)
	# 	# TODO: implement proper help when there are enough tools to make files for each subcommand
	# 	util.help_show_usage_and_flags 'tool'
	# 	util.help_show_cmd_tool_all 'tool'
	# 	exit 0
	# 	;;
	-*)
		util.print_error_die "Flag '$arg' not recognized"
		;;
	*)
		subcmds+=("$arg")
	esac done; unset -v arg

	local subcmd="$1"
	if [ -z "$subcmd" ]; then
		util.help_show_cmd_tool_all 'tool'
		util.print_error_die 'Expected subcommand'
	fi
	if ! shift; then
		util.print_fatal_die 'Failed to shift'
	fi

	if [ "$subcmd" = 'get-exe' ]; then
		local cmd="${subcmds[1]}"
		if [ -z "$cmd" ]; then
			util.print_error_die 'Failed to supply command'
			return
		fi

		helper.toolversions_get_executable_safe "$cmd"
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
		helper.determine_tool_name "$1"
		local tool_name="$REPLY"

		helper.create_version_table "$tool_name" 'yes'

		helper.determine_tool_version "$tool_name" "$2"
		local tool_version="$REPLY"

		local flag_interactive='yes'
		local flag_force='yes'
		helper.install_tool_version "$flag_interactive" "$flag_force" "$tool_name" "$tool_version"
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
		util.toolversions_get_file
		local toolversions_file="$REPLY"
		if [ -n "$toolversions_file" ]; then
			helper.toolversions_set_versions "$toolversions_file"
		fi
	elif [ "$subcmd" = 'install-default-plugins' ]; then
		local dir=
		for dir in "$BASALT_PACKAGE_DIR"/pkg/src/plugins/{for-building,hashicorp,languages,languages-other,misc-tools}/; do
		woof-plugin-install --force "$dir"
		done; unset -v dir
	else
		util.print_error_die "Subcommand '$subcmd' is not valid"
	fi
}
