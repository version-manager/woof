# shellcheck shell=bash

nodejs.private.select_version() {
	local index="$1"; shift

	# cursor to home
	printf '\033[%d;%dH' 0 0 # tput cup 0 0

	# LINES, COLUMNS
	local pointer=
	for ((line=0; line<global_tty_height; line++)); do
		if ((line != 0)); then
			# cursor down one line
			printf '\e[1B' # tput cud1
		fi

		if ((line == global_tty_height / 2)); then
			pointer='> '
		else
			pointer='  '
		fi
		# cursor to start of line, erase from cursor to end of line
		printf '\r\e[0K' # printf '\r'; tput el

		printf '%s' "${pointer}$RANDOM"
	done; unset line
}

nodejs.list() {
	local json=
	if ! json="$(util.fetch -o- https://nodejs.org/download/release/index.json)"; then
		die.code 'FAILED_GET_VERSIONS'
	fi

	ui.select_version 2 "$json"
	local selected_version="$REPLY"

	printf '%s\n' "Selected: $selected_version"
}
