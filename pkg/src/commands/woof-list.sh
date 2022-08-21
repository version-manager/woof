# shellcheck shell=bash

woof-list() {
	local flag_global='no' flag_no_cache='no' flag_all='no'
	local -a plugins=()
	local arg=
	for arg; do case $arg in
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
		core.print_die "Flag '$arg' not recognized"
		;;
	*)
		plugins+=("$arg")
	esac done; unset -v arg

	if [[ "$flag_no_cache" = 'yes' && "$flag_all" = 'no' ]]; then
		core.print_die "Flag --no-cache must only be used with --all"
	fi

	if [[ "$flag_all" = 'yes' && "${#plugins}" -gt 0 ]]; then
		core.print_die "Cannot pass in plugins if passing in '--all'"
	fi

	if [ "$flag_global" = 'yes' ]; then
		util.tool_list_global_versions "$flag_no_cache" "$flag_all" "${plugins[@]}"
	else
		util.tool_list_local_versions "$flag_no_cache" "$flag_all" "${plugins[@]}"
	fi

}
