# shellcheck shell=bash

woof-install() {
	local module_name="$1"
	local version_string="$2"

	local workspace_dir="$WOOF_DATA_HOME/workspace-$module_name"
	local dest_dir="$WOOF_DATA_HOME/installs/$module_name/$version_string"

	if [ -d "$dest_dir" ]; then
		print.die "Version '$version_string' is already installed for module '$module_name'"
	fi

	mkdir -p "$workspace_dir" "${dest_dir%/*}"

	util.get_matrix_value_from_key "$module_name" "$version_string"
	local old_ifs="$IFS"; IFS='|'
	local url= notes=
	read -r url notes <<< "$REPLY"
	IFS="$old_ifs"

	local old_pwd="$PWD"
	mutil.ensure cd -- "$workspace_dir"
	unset REPLY_DIR REPLY_BINS REPLY_MANS
	declare -g REPLY_DIR=
	declare -ag REPLY_BINS=() REPLY_MANS=()
	if "$module_name.install" "$url" "${version_string/#v}"; then
		if err.exists; then
			print.error "$ERR"
			exit "$ERRCODE"
		fi
	else
		print.die "Unexpected error while calling '$module_name.install'"
	fi
	mutil.ensure cd -- "$old_pwd"


	if ! mv "$workspace_dir/$REPLY_DIR" "$dest_dir"; then
		print.die "Could not move extracted contents to '$dest_dir'"
	fi

	if ((${#REPLY_BINS[@]} > 0)); then
		mkdir -p "$WOOF_DATA_HOME/symlinks-global/bin"
	fi

	for reply_bin in "${REPLY_BINS[@]}"; do
		for bin_file in "$dest_dir/$reply_bin"/*; do
			if ! ln -sf "$bin_file" "$WOOF_DATA_HOME/symlinks-global/bin"; then
				print.die "Link failed"
			fi
		done; unset bin_file
	done; unset reply_bin

	rm -rf "$workspace_dir"
}
