# shellcheck shell=bash

woof-list() {
	local -a plugins=()
	local flag_global='no' flag_no_cache='no' flag_all='no'
	local arg=
	for arg; do case $arg in
	--help)
		util.help_show_usage_and_flags 'list'
		util.help_show_part '.list'
		exit 0
		;;
	--global)
		flag_global='yes'
		;;
	--no-cache)
		flag_no_cache='yes'
		;;
	--all)
		flag_all='yes'
		;;
	-*)
		util.print_help_die '.list' "Flag '$arg' not recognized"
		;;
	*)
		plugins+=("$arg")
	esac done; unset -v arg

	if [[ "$flag_no_cache" = 'yes' && "$flag_all" = 'no' ]]; then
		util.print_error_die "Flag --no-cache must only be used with --all"
	fi

	if [[ "$flag_all" = 'yes' && "${#plugins[@]}" -gt 0 ]]; then
		util.print_error_die "Cannot pass in plugins if passing in '--all'"
	fi

	if [ "$flag_global" = 'yes' ]; then
		util.tool_list_global_versions "$flag_no_cache" "$flag_all" "${plugins[@]}"
	else
		util.tool_list_local_versions "$flag_no_cache" "$flag_all" "${plugins[@]}"
	fi

}
