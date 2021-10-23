# shellcheck shell=bash

main.woof() {
	# TODO
	set -eo pipefail
	global_stty_saved=
	global_tty_height=
	global_tty_width=

	WOOF_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/woof"
	WOOF_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/woof"
	WOOF_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}/woof"

	local cmds=()
	for arg; do case "$arg" in
		--detected)
			util.get_detected
			;;
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

	local module_name="${cmds[0]}"; shift
	if [ -z "$module_name" ]; then
		print.die "No module was given"
	fi

	local plugin_file="$BASALT_PACKAGE_DIR/pkg/lib/plugins/$module_name.sh"
	if [ ! -f "$plugin_file" ]; then
		print.die "Module '$module_name' not found"
	fi

	if ! source "$plugin_file"; then
		print.die "Could not successfully source module '$module_name'"
	fi

	local action_name="${cmds[1]}"; shift
	if [ -z "$action_name" ]; then
		print.die "No action was given"
	fi

	if [[ $action_name == *private* ]]; then
		print.die "Specifying private actions is invalid"
	fi

	if ! declare -f "$module_name.$action_name" >/dev/null 2>&1; then
		print.die "Action '$action_name' not defined for module '$module_name'"
	fi
	local version_string="${cmds[2]}"; shift
	if [ -z "$version_string" ]; then
		print.die "No version string was given"
	fi

	local versions=()
	local cached_versions="$WOOF_DATA_HOME/cached/$module_name-versions.txt"

	local use_cache=no
	if [ -f "$cached_versions" ]; then
		util.wcl "$cached_versions"
		if ((REPLY > 3)); then
			use_cache=yes
		fi
	fi

	if [ "$use_cache" = yes ]; then
		readarray -t versions < "$cached_versions"
	else
		local data=
		if ! data="$("$module_name.fetch")"; then
			print.die "Could not execute '$module_name.fetch' successfully"
		fi

		readarray -t versions <<< "$data"

		mkdir -p "${cached_versions%/*}"
		printf '%s' "$data" > "$cached_versions"
		unset data
	fi
	unset use_cache

	if ! util.is_version_valid 'versions' "$version_string" "$cached_versions"; then
		print.die "Version '$version_string' is not valid for module '$module_name'"
	fi

	case "$action_name" in
	install)
		local workspace_dir="$WOOF_DATA_HOME/workspace-$module_name"
		local dest_dir="$WOOF_DATA_HOME/modules/$module_name/$version_string"
		mkdir -p "$workspace_dir" "$dest_dir"

		local old_pwd="$PWD"
		util.ensure_cd "$workspace_dir"

		unset REPLY_BINS REPLY_MANS
		declare -ag REPLY_BINS=() REPLY_MANS=()
		"$module_name.$action_name" "$workspace_dir" "$dest_dir" "${version_string/#v}"

		util.ensure_cd "$old_pwd"
		;;
	uninstall)
		"$module_name.$action_name" ;;
	esac

}
