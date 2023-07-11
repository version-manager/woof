# shellcheck shell=bash

woof-tool() {
	local -a args=()
	local arg=
	for arg; do case $arg in
	--help)
		util.help_show_cmd_tool_all
		exit 0
		;;
	-*)
		util.print_help_die '.tool' "Flag '$arg' not recognized"
		;;
	*)
		args+=("$arg")
	esac done; unset -v arg

	local subcmd="$1"
	if [ -z "$subcmd" ]; then
		util.help_show_cmd_tool_all
		util.print_error_die 'No subcommand was given'
	fi
	if ! shift; then
		util.print_fatal_die 'Failed to shift'
	fi

	if [ "$subcmd" = 'get-exe' ]; then
		local cmd="${args[1]}"
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
		helper.determine_tool_pair_active "$1"
		local tool_name="$REPLY3"

		util.run_function "$tool_name.table"
	elif [ "$subcmd" = 'debug-install' ]; then
		helper.determine_tool_pair_active "$1"
		declare -g g_tool_pair="$REPLY1"
		declare -g g_plugin_name="$REPLY2"
		declare -g g_tool_name="$REPLY3"

		helper.create_version_table "$g_tool_pair" 'yes'

		helper.determine_tool_version_active "$2"
		local g_tool_version="$REPLY"

		local flag_interactive='yes'
		local flag_force='yes'
		helper.install_tool_version "$flag_interactive" "$flag_force" "$g_tool_pair" "$g_tool_version"
	elif [ "$subcmd" = 'dev-release' ]; then
		if [ ! -f 'manifest.ini' ]; then
			util.print_error_die "Failed to find file in current directory: 'manifest.ini'"
		fi

		if [ ! -d '.git' ]; then
			util.print_error_die "Current directory is not a Git repository"
		fi

		local output=
		if ! output=$(git status --porcelain); then
			util.print_error_die "Failed to run 'git status - -porcelain'"
		fi
		if [ -n "$output" ]; then
			util.print_error_die "Aborting because your working directory is dirty"
		fi
		unset -v output

		if ! grep -q 'version *= *' 'manifest.ini'; then
			util.print_error_die "Failed to find a 'version' key in manifest file"
		fi

		local current_version=
		current_version=$(grep 'version *= *' 'manifest.ini' | cut -d= -f2)
		current_version=${current_version#"${current_version%%[![:space:]]*}"}
		current_version=${current_version%"${current_version##*[![:space:]]}"}
		printf '%s\n' "current_version: $current_version"

		local new_version=
		read -rp 'New Version: ' new_version

		if [[ $new_version == v* ]]; then
			util.print_error_die "New version should not be prefixed with a 'v'"
		fi

		sed -Ei'' "s/(version[\\t ]*=[\\t ])(.*)[\\t ]*/\\1$new_version/g" 'manifest.ini'

		git add 'manifest.ini'
		git commit -nm "release: v$new_version"
		git tag -a -m "v$new_version" "v$new_version"
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
		util.path_things
	elif [ "$subcmd" = 'print-eval' ]; then
		util.path_things
	else
		util.print_error_die "Subcommand '$subcmd' is not valid"
	fi
}
