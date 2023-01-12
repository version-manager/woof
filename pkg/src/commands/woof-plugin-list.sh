# shellcheck shell=bash

woof-plugin-list() {
	local flag_all='no' flag_variant='web,local,builtin'
	local arg=
	for arg; do case $arg in
	--show-variants*)
		flag_variant=
		if [[ "$arg" == *=* ]]; then
			flag_variant="${arg#*=}"
		fi

		if [ -z "$flag_variant" ]; then
			util.print_error_die "Option '--show-variants' must have a value"
		fi
		;;
	--show-disabled)
		flag_all='yes'
		;;
	-*)
		util.print_error_die "Flag '$arg' not recognized"
		;;
	esac done; unset -v arg
	flag_variant=",$flag_variant,"

	var.get_dir 'installed-plugins'
	local plugins_dir="$REPLY"


	local dirpath=
	for dirpath in "$plugins_dir"/*; do
		local dirname="${dirpath##*/}"
		local install_type=${dirname%%-*}
		local plugin_slug=${dirname#*-}


		if [[ "$flag_variant" == *"$install_type"* ]]; then
			printf '%s\n' "$install_type: $plugin_slug"
		fi
	done; unset -v
}
