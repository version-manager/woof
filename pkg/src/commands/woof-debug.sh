# shellcheck shell=bash

woof-debug() {
	local possible_module_name="$1"

	helper.determine_module_name "$possible_module_name"
	local module_name="$REPLY"

	util.run_function "$module_name.matrix"
}
