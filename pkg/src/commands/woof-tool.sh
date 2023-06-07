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
		util.print_help_die '.tool' "Flag '$arg' not recognized"
		;;
	*)
		subcmds+=("$arg")
	esac done; unset -v arg

	local subcmd="$1"
	if [ -z "$subcmd" ]; then
		util.help_show_cmd_tool_all
		util.print_help_die '.tool' 'Expected subcommand'
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
		helper.determine_tool_pair "$1"
		local tool_name="$REPLY2"

		util.run_function "$tool_name.table"
	elif [ "$subcmd" = 'debug-install' ]; then
		helper.determine_tool_pair "$1"
		declare -g g_tool_pair="$REPLY"
		declare -g g_plugin_name="$REPLY1"
		declare -g g_tool_name="$REPLY2"

		helper.create_version_table "$g_tool_pair" 'yes'

		helper.determine_tool_version "$2"
		local g_tool_version="$REPLY"

		local flag_interactive='yes'
		local flag_force='yes'
		helper.install_tool_version "$flag_interactive" "$flag_force" "$g_tool_pair" "$g_tool_version"
	elif [ "$subcmd" = 'clear-table-cache' ]; then
		local tool_pair="$1"

		var.get_plugin_table_file "$g_tool_pair"
		local table_file="$REPLY"

		if [ -z "$g_tool_pair" ]; then
			util.print_info "Removing all table cache"
			# Since '$tool_pair' is empty, the basename of '$table_file' is
			# not correct, but that doesn't matter as it is not used here
			rm -rf "${table_file%/*}"
		else
			util.print_info "Removing table cache for '$tool_pair'"
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
	elif [ "$subcmd" = 'generate-plugin-index' ]; then
		printf '%s\n' 'Generating...'

		var.get_dir 'data'
		local index_dir="$REPLY/index"
		rm -rf "$index_dir"
		mkdir -p "$index_dir"

		var.get_dir 'plugins'
		local plugins_dir="$REPLY"

		local plugin_dir=
		core.shopt_push -s 'nullglob'
		for plugin_dir in "$plugins_dir"/*/; do
			local plugin_name="$plugin_dir%/"; plugin_name=${plugin_name##*/}

			# by-plugin
			mkdir -p "$index_dir/by-plugin/$plugin_name"
			local tool_file=
			for tool_file in "$plugin_dir/tools/"*.sh; do
				local tool_pair=${tool_file##*/}; tool_pair=${tool_pair%.sh}

				ln -s "$tool_file" "$index_dir/by-plugin/$plugin_name/$tool_pair"
			done; unset -v f file_name file_name_no_ext

			# by-tool
			mkdir -p "$index_dir/by-tool"

			# by-tag
			mkdir -p "$index_dir/by-tag"
		done
		unset -v plugin_dir
		core.shopt_pop

		printf '%s\n' 'Done.'
	else
		util.print_error_die "Subcommand '$subcmd' is not valid"
	fi
}
