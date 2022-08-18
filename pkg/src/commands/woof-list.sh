# shellcheck shell=bash

woof-list() {
	local flag_no_cache='no' flag_all='no'
	local arg=
	for arg; do case $arg in
	--no-cache)
		flag_no_cache='yes'
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

	local possible_plugin_name="${subcmds[0]}"


	helper.determine_plugin_name "$possible_plugin_name"
	local plugin_name="$REPLY"
	unset -v possible_plugin_name

	if [ "$flag_all" = 'yes' ]; then
		helper.create_version_table "$plugin_name" "$flag_no_cache"

		util.uname_system
		local real_os="$REPLY1"
		local real_arch="$REPLY2"

		var.get_plugin_table_file "$plugin_name"
		local table_file="$REPLY"

		local variant= version= os= arch= url= comment=
		while IFS='|' read -r variant version os arch url comment; do
			if [ "$real_os" = "$os" ] && [ "$real_arch" = "$arch" ]; then
				printf '%s\n' "$version"
			fi
		done < "$table_file" | util.sort_versions
		unset -v variant version os arch url comment
	else
		var.get_dir 'installs' "$plugin_name"
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
