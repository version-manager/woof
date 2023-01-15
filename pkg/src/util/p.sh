# shellcheck shell=bash

p.ensure() {
	if "$@"; then :; else
		util.print_error_die "Command '$*' failed (code $?)"
	fi
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

	util.print_info "Fetching $url"

	# --progress-bar goes to standard error
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
	util.print_info 'Unpacking' "$REPLY"

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

p.run_bash() {
	local file="$1"

	# Ex. 'p.run_bash "$BASALT_PACKAGE_DIR/pkg/src/filters/hashicorp.sh" "consul"'
	if [[ ${file::1} == '/' ]]; then
		bash "$@"
	# Ex. 'p.run_bash "hashicorp" "consul"'
	elif [[ $file =~ ^[[:alpha:]]+$ ]]; then
		bash "$BASALT_PACKAGE_DIR/pkg/src/filters/$file.sh" "${@:2}"
	else
		bash "$@"
	fi
}

p.run_jq() {
	local file="$1"

	# Note: with --arg, the first one specified as an argument takes presidence

	# Ex. 'p.run_jq "$BASALT_PACKAGE_DIR/pkg/src/filters/crystal.jq"'
	if [[ ${file::1} == '/' ]]; then
		jq -L "$BASALT_PACKAGE_DIR/pkg/src/filters/util" -rf "$@" "${@:2}" --arg global_default_arch ''
	# Ex. 'p.run_jq "crystal"'
	elif [[ $file =~ ^[[:alpha:]_-]+$ ]]; then
		local jq_file="$BASALT_PACKAGE_DIR/pkg/src/filters/$file.jq"

		jq -L "$BASALT_PACKAGE_DIR/pkg/src/filters/util" -rf "$jq_file" "${@:2}" --arg global_default_arch ''
	else
		jq -L "$BASALT_PACKAGE_DIR/pkg/src/filters/util" "$@"
	fi
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
