# shellcheck shell=bash

woof-set-global() {
	local possible_module_name="$1"
	local possible_version_string="$2"

	helper.determine_module_name "$possible_module_name"
	local module_name="$REPLY"

	helper.determine_installed_version_string "$module_name" "$possible_version_string"
	local version_string="$REPLY"

	printf '%s\n' "Setting version '$version_string' as global version"

	local module_name="$1"
	local version_string="$2"

	local install_dir="$WOOF_DATA_HOME/installs/$module_name/$version_string"

	local -a bin_files=()
	local -a man_files=()
	while IFS='=' read -r key value; do
		if [ "$key" = 'bins' ]; then
			IFS=':' read -ra bin_files <<< "$value"
		elif [ "$key" = 'mans' ]; then
			IFS=':' read -ra man_files <<< "$value"
		fi
	done < "$install_dir/data.txt"

	if ((${#bin_files[@]} > 0)); then
		mkdir -p "$WOOF_DATA_HOME/symlinks-global/bin"
	fi

	for reply_bin in "${bin_files[@]}"; do
		if [ -d "$install_dir/files/$reply_bin" ]; then
			for bin_file in "$install_dir/files/$reply_bin"/*; do
				if [ ! -x "$bin_file" ]; then
					print.warn "File '$bin_file' is in a bin directory, but is not marked as executable"
					continue
				fi

				if ! ln -sf "$bin_file" "$WOOF_DATA_HOME/symlinks-global/bin"; then
					print.warn "Link failed. Continuing execution"
				fi
			done; unset bin_file
		else
			print.warn "Directory '$reply_bin' does not exist for module '$module_name'"
		fi
	done; unset reply_bin
}
