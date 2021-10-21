# shellcheck shell=bash

main.woof() {
	util.init

	local plugin_name="$1"
	local subcommand="$2"
	shift 2


	local plugin_file="$BASALT_PACKAGE_DIR/pkg/lib/plugins/$plugin_name.sh"
	if [ ! -f "$plugin_file" ]; then
		printf '%s\n' "Error: Plugin '$plugin_name' not found"
		exit 1
	fi

	if ! source "$plugin_file"; then
		printf '%s\n' "Error when sourcing '$plugin_file'"
		exit 1
	fi

	local fn_name="$plugin_name"."$subcommand"
	if ! declare -f "$fn_name" >/dev/null 2>&1; then
		printf '%s\n' "Error function '$fn_name' not implemented"
		exit 1
	fi

	"$fn_name" "$@"
}
