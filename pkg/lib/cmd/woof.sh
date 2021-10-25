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
	if [ -z "$version_string" ]; then
		local -a matrix_keys=()
		local -A matrix_table=()

		util.construct_version_matrix "$module_name" matrix_keys matrix_table
		util.select_version "$module_name" matrix_keys matrix_table
		version_string="$REPLY"

		unset matrix_keys matrix_table
	fi

	printf '%s\n' "Chosen: $version_string"
	if ! util.get_module_value_from_key "$module_name" "$version_string"; then
		print.die "Version '$version_string' is not valid for module '$module_name'"
	fi
	unset REPLY

	case "$action_name" in
	install)
		local workspace_dir="$WOOF_DATA_HOME/workspace-$module_name"
		local dest_dir="$WOOF_DATA_HOME/installs/$module_name/$version_string"

		if [ -d "$dest_dir" ]; then
			print.die "Version '$version_string' is already installed for module '$module_name'"
		fi

		mkdir -p "$workspace_dir" "${dest_dir%/*}"

		util.get_module_value_from_key "$module_name" "$version_string"
		local old_ifs="$IFS"; IFS='|'
		local url= notes=
		read -r url notes <<< "$REPLY"
		IFS="$old_ifs"

		local old_pwd="$PWD"
		util.ensure_cd "$workspace_dir"
		unset REPLY_DIR REPLY_BINS REPLY_MANS
		declare -g REPLY_DIR=
		declare -ag REPLY_BINS=() REPLY_MANS=()
		if "$module_name.install" "$url" "${version_string/#v}"; then
			if err.exists; then
				print.error "$ERR"
				exit "$ERRCODE"
			fi
		else
			print.die "Unexpected error while calling '$module_name.install'"
		fi
		util.ensure_cd "$old_pwd"


		if ! mv "$workspace_dir/$REPLY_DIR" "$dest_dir"; then
			print.die "Could not move extracted contents to '$dest_dir'"
		fi

		if ((${#REPLY_BINS[@]} > 0)); then
			mkdir -p "$WOOF_DATA_HOME/symlinks-global/bin"
		fi

		for reply_bin in "${REPLY_BINS[@]}"; do
			for bin_file in "$dest_dir/$reply_bin"/*; do
				if ! ln -sf "$bin_file" "$WOOF_DATA_HOME/symlinks-global/bin"; then
					print.die "Link failed"
				fi
			done; unset bin_file
		done; unset reply_bin

		rm -rf "$workspace_dir"

		;;
	uninstall)
		local install_dir="$WOOF_DATA_HOME/installs/$module_name/$version_string"
		if [ -e "$install_dir" ]; then
			rm -rf "$install_dir"
			print.info "Removed version '$version_string' for module '$module_name'"
		else
			print.die "Version '$version_string' for module '$module_name' is not installed"
		fi
		;;
	esac
}
