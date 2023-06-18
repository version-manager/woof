# shellcheck shell=bash

main.woof() {
	# If current Bash doesn't meet minimum requirements, search for one that does. Woof is able
	# to install ancient versions of Bash, so this logic significantly improves UX
	if ! ((BASH_VERSINFO[0] >= 5 || (BASH_VERSINFO[0] >= 4 && BASH_VERSINFO[1] >= 3) )); then
		if [ -n "${BASH_INTERNAL_VERSIONEXEC+x}" ]; then
			printf '%s\n' "Error: Woof: Exec'ed, but version requirements still not satisfied. Aborting to prevent infinite loops"
			exit 1
		fi

		local -a bin_dirs=()
		IFS=':' read -ra bin_dirs <<< "$PATH"

		local bin_dir=
		for bin_dir in "${bin_dirs[@]}"; do
			if [ -x "$bin_dir/bash" ]; then
				local output=
				output=$("$bin_dir/bash" --version)
				output=${output#"GNU bash, version "}

				local major_ver=${output%%.*}
				output=${output#*.}
				local minor_ver=${output%%.*}

				if ((major_ver >= 5 || (major_ver >= 4 && minor_ver >= 3) )); then
					printf '%s\n' "Warning: Woof: Bash version from '/usr/bin/env bash' of '$BASH_VERSION' is too low; exec'ing into a newer one: $bin_dir/bash" >&2
					BASH_INTERNAL_VERSIONEXEC= exec "$bin_dir/bash" "${BASH_SOURCE[1]}" "$@"
				fi
			fi
		done; unset -v bin_dir

		printf '%s\n' "Error: Woof: Failed to meet minimum Bash requirement of 4.3 and failed to find newer version in PATH" >&2
		exit 1
	fi

	global_trap_err() {
		core.print_stacktrace
	}
	core.trap_add 'global_trap_err' 'ERR'

	global_stty_saved=
	g_tty_height=
	g_tty_width=

	: "${WOOF_CONFIG_HOME:=${XDG_CONFIG_HOME:-$HOME/.config}/woof}"
	: "${WOOF_CACHE_HOME:=${XDG_CACHE_HOME:-$HOME/.cache}/woof}"
	: "${WOOF_DATA_HOME:=${XDG_DATA_HOME:-$HOME/.local/share}/woof}"
	: "${WOOF_STATE_HOME:=${XDG_STATE_HOME:-$HOME/.local/state}/woof}"
	WOOF_VARS='WOOF_CONFIG_HOME WOOF_CACHE_HOME WOOF_DATA_HOME WOOF_STATE_HOME'

	# Validate the existence of GitHub token
	local token_file="$WOOF_DATA_HOME/token"
	if [ -f "$token_file" ]; then
		if ! GITHUB_TOKEN=$(<"$token_file"); then
			util.print_error_die "Failed to read from file '$token_file'"
		fi
		export GITHUB_TOKEN
	else
		util.print_error_die "Must have a file containing your GitHub token at '$token_file'"
	fi
	unset -v token_file

	# Parse arguments
	local g_flag_quiet='no'
	local arg=
	for arg; do case $arg in
	--help|-h)
		util.help_show_cmd_root_all
		exit 0
		;;
	--quiet|-q)
		# shellcheck disable=SC2034
		g_flag_quiet='yes'
		if ! shift; then
			util.print_fatal_die 'Failed to shift'
		fi
		;;
	-*)
		util.print_error_die "Global flag '$arg' not recognized"
		;;
	*)
		break
		;;
	esac done; unset -v arg

	# Get action name
	local subcommand="$1"
	if [ -z "$subcommand" ]; then
		util.help_show_cmd_root_all
		util.print_error_die 'No subcommand was given'
	fi
	if ! shift; then
		util.print_fatal_die 'Failed to shift'
	fi

	# shellcheck disable=SC1090
	case $subcommand in
		init)
			source "$BASALT_PACKAGE_DIR/pkg/src/commands/woof-$subcommand.sh"
			woof-init "$@"
			;;
		install)
			source "$BASALT_PACKAGE_DIR/pkg/src/commands/woof-$subcommand.sh"
			woof-install "$@"
			;;
		uninstall)
			source "$BASALT_PACKAGE_DIR/pkg/src/commands/woof-$subcommand.sh"
			woof-uninstall "$@"
			;;
		get-version)
			source "$BASALT_PACKAGE_DIR/pkg/src/commands/woof-$subcommand.sh"
			woof-get-version "$@"
			;;
		set-version)
			source "$BASALT_PACKAGE_DIR/pkg/src/commands/woof-$subcommand.sh"
			woof-set-version "$@"
			;;
		exec)
			source "$BASALT_PACKAGE_DIR/pkg/src/commands/woof-$subcommand.sh"
			woof-exec "$@"
			;;
		list)
			source "$BASALT_PACKAGE_DIR/pkg/src/commands/woof-$subcommand.sh"
			woof-list "$@"
			;;
		plugin)
			source "$BASALT_PACKAGE_DIR/pkg/src/commands/woof-$subcommand.sh"
			woof-plugin "$@"
			;;
		tool)
			source "$BASALT_PACKAGE_DIR/pkg/src/commands/woof-$subcommand.sh"
			woof-tool "$@"
			;;
		*)
			util.print_error_die "Subcommand '$subcommand' not recognized"
			;;
	esac
}
