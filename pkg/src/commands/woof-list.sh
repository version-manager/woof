# shellcheck shell=bash

woof-list() {
	local flag_available='no'
	local arg=
	for arg; do case $arg in
	--available)
		flag_available='yes'
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

	if [ "$flag_available" = 'yes' ]; then
		helper.create_version_matrix "$module_name"

		util.uname_system
		local real_os="$REPLY1"
		local real_arch="$REPLY2"

		var.get_cached_matrix_file "$module_name"
		local matrix_file="$REPLY"

		local variant= version= os= arch= url= comment=
		while IFS='|' read -r variant version os arch url comment; do
			if [ "$flag_all" == 'yes' ]; then
				printf '%s\n' "$version"
			else
				if [ "$real_os" = "$os" ] && [ "$real_arch" = "$arch" ]; then
					printf '%s\n' "$version"
				fi
			fi
		done < "$matrix_file" | sort -V
		unset -v variant version os arch url comment
	else
		var.get_module_install_dir "$module_name"
		local install_dir="$REPLY"

		core.shopt_push -s nullglob
		local -a versions=("$install_dir"/*/)
		core.shopt_pop
		versions=("${versions[@]%/}")
		versions=("${versions[@]##*/}")

		local version=
		for version in "${versions[@]}"; do
			printf '%s\n' "$version"
		done; unset -v version
	fi
}
