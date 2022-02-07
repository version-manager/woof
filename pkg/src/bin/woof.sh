# shellcheck shell=bash

# Credit to yoctu for this
do_trace() {
	local err=$?

	printf '%s\n' "Error in ${BASH_SOURCE[1]}:${BASH_LINENO[0]}. '${BASH_COMMAND}' exited with status $err"

	if (( ${#FUNCNAME[@]} >> 2 )); then
		printf '%s\n' "Call stack:"
		for ((i=1;i<${#FUNCNAME[@]}-1;i++)); do
			printf '%s\n' " $i: ${BASH_SOURCE[$i+1]}:${BASH_LINENO[$i]} ${FUNCNAME[$i]}(...)"
		done
	fi

	printf '%s\n' "Exiting with status ${err}"
	exit $err
}

main.woof() {
	core.init

	trap do_trace ERR EXIT

	global_stty_saved=
	global_tty_height=
	global_tty_width=

	WOOF_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/woof"
	WOOF_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/woof"
	WOOF_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}/woof"

	local subcmds=()
	for arg; do case "$arg" in
		--help|-h)
			util.show_help
			exit
			;;
		-*)
			print.die "Flag '$arg' not recognized"
			;;
		*)
			subcmds+=("$arg")
			;;
	esac done; unset arg

	# Get action name
	local action_name="${subcmds[0]}"
	if [ -z "$action_name" ]; then
		util.show_help
		print.die "No action was given"
	fi

	case "$action_name" in
	init)
		woof-init
		;;
	install)
		helper.get_module_name "${subcmds[1]}"
		local module_name="$REPLY"

		helper.create_version_matrix "$module_name"

		helper.get_version_string "$module_name" "${subcmds[2]}"
		local version_string="$REPLY"

		printf '%s\n' "Installing $version_string"
		woof-install "$module_name" "$version_string"
		;;
	uninstall)
		helper.get_module_name "${subcmds[1]}"
		local module_name="$REPLY"

		helper.get_installed_version_string "$module_name" "${subcmds[2]}"
		local version_string="$REPLY"

		printf '%s\n' "Uninstalling $version_string"
		woof-uninstall "$module_name" "$version_string"
		;;
	current)

		;;
	list)
		helper.get_module_name "${subcmds[1]}"
		local module_name="$REPLY"

		woof-list "$module_name"
		;;
	set-global)
		helper.get_module_name "${subcmds[1]}"
		local module_name="$REPLY"

		helper.get_installed_version_string "$module_name" "${subcmds[2]}"
		local version_string="$REPLY"

		printf '%s\n' "Setting version '$version_string' as global version"
		woof-set-global "$module_name" "$version_string"
		;;
	*)
		print.die "Action '$action_name' not recognized"
		;;
	esac
}
