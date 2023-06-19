# shellcheck shell=bash

woof-plugin-install() {
	local -a plugins=()
	local flag_force='no'
	local arg=
	for arg; do case $arg in
	--help)
		util.help_show_usage_and_flags 'plugin install'
		util.help_show_part '.plugin.install'
		exit 0
		;;
	--force)
		flag_force='yes'
		;;
	-*)
		util.print_help_die '.plugin.install' "Flag '$arg' not recognized"
		;;
	*)
		plugins+=("$arg")
	esac done; unset -v arg

	helper.plugin_install "$flag_force" "${plugins[@]}"
}
