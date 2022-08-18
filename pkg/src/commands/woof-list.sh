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
		core.print_die "Flag '$arg' not recognized"
		;;
	*)
		subcmds+=("$arg")
		shift
	esac done; unset -v arg

	local possible_module_name="${subcmds[0]}"


	helper.determine_module_name "$possible_module_name"
	local module_name="$REPLY"
	unset -v possible_module_name

	if [ "$flag_installed" = 'yes' ]; then
		helper.create_version_table "$module_name"

		util.uname_system
		local real_os="$REPLY1"
		local real_arch="$REPLY2"

		var.get_module_table_file "$module_name"
		local table_file="$REPLY"

		local variant= version= os= arch= url= comment=
		while IFS='|' read -r variant version os arch url comment; do
			if [ "$flag_all" == 'yes' ]; then
				printf '%s\n' "$version"
			else
				if [ "$real_os" = "$os" ] && [ "$real_arch" = "$arch" ]; then
					printf '%s\n' "$version"
				fi
			fi
		done < "$table_file" | sort -V
		unset -v variant version os arch url comment
	else
		var.get_dir 'installs' "$module_name"
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
		if (( ${#versions[@]} == 0)); then
			term.style_italic -Pd 'No items'
		fi
	fi
}
