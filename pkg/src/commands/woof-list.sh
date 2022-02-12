# shellcheck shell=bash

woof-list() {
	local possible_module_name="$1"

	core.shopt_push -s nullglob

	local -a versions=("$WOOF_DATA_HOME/installs/$module_name"/*/)
	core.shopt_pop
	versions=("${versions[@]%/}")
	versions=("${versions[@]##*/}")

	local version=
	for version in "${versions[@]}"; do
		printf '%s\n' "$version"
	done; unset -v version
}
