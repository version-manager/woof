# shellcheck shell=bash

main.woof() {
	# TODO
	set +e # ex. shift
	set -o pipefail

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
	install)
		helper.get_module_name "${subcmds[1]}"
		local module_name="$REPLY"

		helper.get_version_string "${subcmds[2]}"
		local version_string="$REPLY"

		printf '%s\n' "Chosen: $version_string"
		return
		woof-install "$module_name" "$version_string"
		;;
	uninstall)
		helper.get_module_name "${subcmds[1]}"
		local module_name="$REPLY"

		helper.get_version_string "${subcmds[2]}"
		local version_string="$REPLY"

		woof-uninstall "$module_name" "$version_string"
		;;
	*)
		print.die "Action '$action_name' not recognized"
		;;
	esac
}
