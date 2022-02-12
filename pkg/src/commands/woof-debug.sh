# shellcheck shell=bash

woof-debug() {
	local module="$1"

	helper.determine_module_name "${subcmds[1]}"
	local module_name="$REPLY"

	util.run_function "$module_name.matrix"
}
