# shellcheck shell=bash

woof-install() {
	local possible_module_name="$1"
	local possible_version_string="$2"

	helper.determine_module_name "$possible_module_name"
	local module_name="$REPLY"

	helper.create_version_matrix "$module_name"

	helper.determine_version_string "$module_name" "$possible_version_string"
	local version_string="$REPLY"

	unset -v possible_module_name
	unset -v possible_version_string

	local workspace_dir="$WOOF_DATA_HOME/workspace-$module_name"
	local install_dir="$WOOF_DATA_HOME/installs/$module_name/$version_string"
	local current_choice_file="$WOOF_STATE_HOME/current-choice/$module_name"

	# If already installed
	if [ -d "$install_dir" ]; then
		mkdir -p "${current_choice_file%/*}"
		if ! printf '%s\n' "$selected_version" > "$current_choice_file"; then
			rm -f "$current_choice_file"
			print.die "Could not write to '$current_choice_file'"
		fi

		print.die "Version '$version_string' is already installed for module '$module_name'. Setting as default"
	fi

	# Preparation actions
	rm -rf "$workspace_dir"
	mkdir -p "$workspace_dir" "$install_dir"

	util.get_matrix_row "$module_name" "$version_string"
	local url="$REPLY1"

	util.uname_system
	local os="$REPLY1"
	local arch="$REPLY2"

	# Execute '<module>.install'
	printf '%s\n' "Installing $version_string"
	local old_pwd="$PWD"
	m.ensure cd -- "$workspace_dir"
	unset REPLY_DIR REPLY_BINS REPLY_MANS
	declare -g REPLY_DIR=
	declare -ag REPLY_BINS=() REPLY_MANS=()
	if "$module_name.install" "$url" "${version_string/#v}" "$os" "$arch"; then
		if core.err_exists; then
			rm -rf "$workspace_dir"
			print.error "$ERR"
			exit "$ERRCODE"
		fi
	else
		rm -rf "$workspace_dir"
		print.die "Unexpected error while calling '$module_name.install'"
	fi
	m.ensure cd -- "$old_pwd"

	# Move extracted contents to 'installs' directory
	if ! mv "$workspace_dir/$REPLY_DIR" "$install_dir/files"; then
		rm -rf "$workspace_dir"
		print.die "Could not move extracted contents to '$install_dir/files'"
	fi

	# Save information about bin, man, etc. pages later
	local old_ifs="$IFS"; IFS=':'
	if ! printf '%s\n' "bins=${REPLY_BINS[*]}
mans=${REPLY_MANS[*]}" > "$install_dir/data.txt"; then
		rm -rf "$workspace_dir" "$install_dir"
		print.die "Could not write to '$install_dir/data.txt'"
	fi
	IFS="$old_ifs"

	rm -rf "$workspace_dir"
}
