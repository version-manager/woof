# shellcheck shell=bash

woof-tool() {
	local subcmd="$1"
	if [ -z "$subcmd" ]; then
		util.show_help
		print.die 'Expected subcommand'
	fi
	if ! shift; then
		print.die 'Failed to shift'
	fi

	if [ "$subcmd" = 'info' ]; then
		:
	elif [ "$subcmd" = 'print-dirs' ]; then
		local var_name=
		for var_name in WOOF_CONFIG_HOME WOOF_CACHE_HOME WOOF_DATA_HOME WOOF_STATE_HOME; do
			local -n var_value="$var_name"
		
			printf '%s\n' "---------- $var_name ----------"
			if [ -d "$var_value" ]; then
				tree -aL 2 --filelimit 15 --noreport "$var_value"
			else
				printf '\033[3m%s\033[0m\n' '  Does not exist'	# TODO: term-info
			fi
			printf '\n'
		done; unset -v var_name
	elif [ "$subcmd" = 'debug-matrix' ]; then
		local possible_module_name="$1"

		helper.determine_module_name "$possible_module_name"
		local module_name="$REPLY"
		unset -v possible_module_name

		util.run_function "$module_name.matrix"
	elif [ "$subcmd" = 'debug-install' ]; then
		local possible_module_name="$1"
		local possible_version_string="$2"

		helper.determine_module_name "$possible_module_name"
		local module_name="$REPLY"
		unset -v possible_module_name
		
		helper.create_version_matrix "$module_name"

		helper.determine_version_string "$module_name" "$possible_version_string"
		local version_string="$REPLY"
		unset -v possible_version_string

		helper.install_module_version --interactive "$module_name" "$version_string"
	elif [ "$subcmd" = 'cache-clear-matrix' ]; then
		local module_name="$1"

		var.get_cached_matrix_file "$module_name"
		local matrix_file="$REPLY"

		if [ -z "$module_name" ]; then
			print.info "Removing all matrix cache"
			# Since '$module_name' is empty, the basename of '$matrix_file' is
			# not correct, but that doesn't matter as it is not used here
			rm -rf "${matrix_file%/*}"
		else
			print.info "Removing matrix cache for '$module_name'"
			rm -f "$matrix_file"
		fi
	else
		print.die "Subcommand '$subcmd' is not valid"
	fi
}
