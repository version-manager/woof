# shellcheck shell=bash

woof-list() {
	local flag_installed='no'
	local arg=
	for arg; do case $arg in
	--installed)
		flag_installed='yes'
		;;
	--all)
		flag_all='yes'
		;;
	-*)
		print.die "Flag '$arg' not recognized"
		;;
	*)
		subcmds+=("$arg")
		shift
	esac done; unset -v arg

	local possible_module_name="${subcmds[0]}"

	helper.determine_module_name "$possible_module_name"
	local module_name="$REPLY"

	if [ "$flag_installed" = 'yes' ]; then
		core.shopt_push -s nullglob
		local -a versions=("$WOOF_DATA_HOME/installs/$module_name"/*/)
		core.shopt_pop
		versions=("${versions[@]%/}")
		versions=("${versions[@]##*/}")

		local version=
		for version in "${versions[@]}"; do
			printf '%s\n' "$version"
		done; unset -v version
	else
		helper.create_version_matrix "$module_name"

		util.uname_system
		local real_os="$REPLY1"
		local real_arch="$REPLY2"

		local matrix_file="$WOOF_DATA_HOME/cached/$module_name-matrix.txt"
		local line=
		while IFS='|' read -r version os arch url comment; do
			if [ "$flag_all" == 'yes' ]; then
				printf '%s\n' "$version"
			else
				if [ "$real_os" = "$os" ] && [ "$real_arch" = "$arch" ]; then
					printf '%s\n' "$version"
				fi
			fi
		done < "$matrix_file" | sort -V
		unset version os arch url comment

		while IFS= read -r line; do


			printf '%s\n' "${line%%|*}"
		done < "$matrix_file" | sort -V

		unset -v line
	fi
}
