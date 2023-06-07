# shellcheck shell=bash

p.ensure() {
	if "$@"; then :; else
		util.print_error_die "Command '$*' failed (code $?)"
	fi
}

p.rmln() {
	local target="$1"
	local link="$2"

	p.ensure rm -rf "$link"
	p.ensure ln -sf "$target" "$link"
}

p.cd() {
	local dir="$1"

	p.ensure cd -- "$dir"
}

p.mkdir() {
	local dir="$1"

	p.ensure mkdir -p -- "$dir"
}

p.fetch() {
	local url=

	local arg=
	for arg; do case $arg in
	-*)
		continue
		;;
	*)
		url=$arg
		;;
	esac done; unset -v arg

	if [ "$g_flag_dry_run" = 'yes' ]; then
		util.print_info "Would have fetched $url"
		return
	else
		util.print_info "Fetching $url"
	fi

	# progress-bar goes to standard error
	if [ -t 2 ]; then
		# TODO: Alternate screen should have same contents as current screen to prevent jarding
		# core.trap_add 'tty.all_restore' INT
		# tty.all_save
		# util.print_info 'Fetching' "$url"
		p.ensure curl -fSL --progress-bar "$@"
		# tty.all_restore
		# core.trap_remove 'tty.all_restore' INT
	else
		p.ensure curl -fsSL "$@"
	fi

}

p.unpack() {
	local file= flag_directory= flag_strip='no'

	local arg=
	for arg; do case $arg in
		-d*) flag_directory=${arg#-d} ;;
		-s) flag_strip='yes' ;;
		*) file=$arg ;;
	esac done; unset -v arg

	local file="$1"
	if ! shift; then
		util.print_error_die "Failed to shift"
	fi

	util.sanitize_path "$PWD/$file"
	if [ "$g_flag_dry_run" = 'yes' ]; then
		util.print_info "Would have unpacked: $REPLY"
		return
	else
		util.print_info 'Unpacking' "$REPLY"
	fi

	if command -v pv &>/dev/null; then
		pv "$file"
	else
		cat "$file"
	fi | if [[ $file == *.tar* ]]; then
		local -a args=()
		if [ -n "$flag_directory" ]; then
			args+=('-C' "$flag_directory")
		fi
		if [ "$flag_strip" = 'yes' ]; then
			args+=('--strip-components=1')
		fi

		tar xf "$file" "${args[@]}"
	elif [[ $file == *.zip ]]; then
		local -a args=()
		if [ -n "$flag_directory" ]; then
			args+=('-d' "$flag_directory")
		fi
		if [ "$flag_strip" = 'yes' ]; then
			core.print_fatal_die "Cannot use strip with zip files"
		fi

		p.ensure unzip -qq "$file" "${args[@]}"
	else
		util.print_error_die "Failed to extract file: '$file'"
	fi
}

p.run_filter() {
	local input="$1"

	var.get_dir 'plugins'
	local plugins_dir="$REPLY"

	if [[ ${input::1} == '/' ]]; then
		p.run_file "$input" "${@:2}"
	else
		if [ -f "$plugins_dir/woof-plugin-$WOOF_PLUGIN_NAME/tools/filters/$input" ]; then
			p.run_file "$plugins_dir/woof-plugin-$WOOF_PLUGIN_NAME/tools/filters/$input" "${@:2}"
		else
			util.print_error_die "Failed to find filter for argument: '$input'"
		fi
	fi
}

p.run_file() {
	local file="$1"

	case $file in
	*.sh)
		bash "$file" "${@:2}"
		;;
	*.bash)
		bash "$file" "${@:2}"
		;;
	*.jq)
		jq -L "$BASALT_PACKAGE_DIR/pkg/src/filter_utils" -rf "$file" "${@:2}" --arg global_default_arch ''
		;;
	*.pl)
		perl "$file" "${@:2}"
		;;
	*)
		util.print_error_die "No runner found for file: '$file'"
	esac
}

p.fetch_git_tags() {
	local url="$1"

	local {_,refspec}=
	while read -r _ refspec; do
		printf '%s\n' "${refspec#refs/tags/}"
	done < <(git ls-remote --refs --tags "$url")
}

p.fetch_github_release() {
	local repo="$1"

	local -i has_more_pages=2 i=1
	for ((i=1; has_more_pages==2; ++i)); do
		local url="https://api.github.com/repos/$repo/releases?per_page=100&page=$i"

		# Use 'curl' over p.fetch
		if curl -fsSL -H "Authorization: token $GITHUB_TOKEN" "$url" \
			| jq 'if length == 0 then "" else . end | if . == "" then halt_error(29) else . end'
		then :; else
			local exit_code=$?

			if ((exit_code == 0)); then
				continue
			elif ((exit_code == 29)); then # '29' is not taken by curl
				has_more_pages=0
			else
				util.print_error_die "Failed to execute curl or jq"
			fi
		fi
	done
}
