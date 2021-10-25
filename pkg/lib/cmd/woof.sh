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

	local cmds=()
	for arg; do case "$arg" in
		--help|-h)
			util.show_help
			exit
			;;
		-*)
			print.die "Flag '$arg' not recognized"
			;;
		*)
			cmds+=("$arg")
			;;
	esac done; unset arg


	# Get action name
	local action_name="${cmds[0]}"
	if [ -z "$action_name" ]; then
		util.show_help
		print.die "No action was given"
	fi

	case "$action_name" in
		install|uninstall) ;;
		*) print.die "Action '$action_name' not recognized" ;;
	esac


	# Get module name
	local module_name="${cmds[1]}"
	if [ -z "$module_name" ]; then
		print.die "No module was given"
	fi

	local plugin_file="$BASALT_PACKAGE_DIR/pkg/lib/modules/$module_name.sh"
	if [ ! -f "$plugin_file" ]; then
		print.die "Module '$module_name' not found"
	fi

	if ! source "$plugin_file"; then
		print.die "Could not successfully source module '$module_name'"
	fi


	# Get version string
	local version_string="${cmds[2]}"
	# 'matrix_table' is an associative array containing keys that look like
	# 'v0.8.6|linux|x86' and values that look like 'https://nodejs.org/download/
	# release/v0.8.6/node-v0.8.6-linux-x86.tar.gz|(Released 2012-08-06)'
	# 'matrix_keys' is just a list that contains every key in 'matrix_table'. It
	# is a separate order so we can change easily change / guarantee ordering
	local -a matrix_keys=()
	local -A matrix_table=()
	if [ -z "$version_string" ]; then
		util.construct_version_matrix "$module_name" matrix_keys matrix_table
		# for key in "${matrix_keys[@]}"; do
		# 	printf '%s\n' "$key: ${matrix_table["$key"]}"
		# done; unset key

		util.select_version matrix_keys matrix_table
		# The selected reply is 
		echo "uwu: $REPLY"
	fi


	# local cached_versions="$WOOF_DATA_HOME/cached/$module_name-versions.txt"
	# if ! util.is_version_valid 'versions' "$version_string" "$cached_versions"; then
	# 	print.die "Version '$version_string' is not valid for module '$module_name'"
	# fi

	# case "$action_name" in
	# install)
	# 	local workspace_dir="$WOOF_DATA_HOME/workspace-$module_name"
	# 	local dest_dir="$WOOF_DATA_HOME/modules/$module_name/$version_string"
	# 	mkdir -p "$workspace_dir" "$dest_dir"

	# 	local old_pwd="$PWD"
	# 	util.ensure_cd "$workspace_dir"

	# 	unset REPLY_BINS REPLY_MANS
	# 	declare -ag REPLY_BINS=() REPLY_MANS=()
	# 	"$module_name.$action_name" "$workspace_dir" "$dest_dir" "${version_string/#v}"

	# 	util.ensure_cd "$old_pwd"
	# 	;;
	# uninstall)
	# 	"$module_name.$action_name" ;;
	# esac

}
