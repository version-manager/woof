# shellcheck shell=bash

global_stty_saved=
util.init() {
	trap g.stty_init SIGCONT
	g.stty_init() {
		global_stty_saved="$(stty --save)"
		stty -echo
		tput civis 2>/dev/null # cursor to invisible
		tput sc # save cursor position
		tput smcup 2>/dev/null # save screen contents

		clear
		read -r global_tty_height global_tty_width < <(stty size)
	}

	trap 'g.stty_deinit; exit' EXIT SIGHUP SIGABRT SIGINT SIGQUIT SIGTERM SIGTSTP
	g.stty_deinit() {
		tput rmcup 2>/dev/null # restore screen contents
		tput rc # restore cursor position
		tput cnorm 2>/dev/null # cursor to normal
		stty "$global_stty_saved"
	}

	trap trap.sigwinch SIGWINCH
	trap.sigwinch() {
		read -r global_tty_height global_tty_width < <(stty size)
	}

	g.stty_init
}

util.versions_from_git() {
	local variable_name="$1"
	local url="$2"
	local prefix="$3"

	local -n variable="$variable_name"
	local prefix_length="${#prefix}"
	while read -r _sha1 refspec; do
		if [ "${refspec:0:$prefix_length}" = "$prefix" ]; then
			variable+=("${refspec:$prefix_length}")
		fi
	done < <(git ls-remote --refs --tags "$url")
	unset _sha1 refspec
}

util.array_filter_out() {
	local array_name="$1"
	local pattern="$2"

	local -n array="$array_name"
	local new_array=("${array[@]}")
	for ((i=0; i<${#array[@]}; i++)); do
		# shellcheck disable=SC2053
		if [[ ${array[i]} != $pattern ]]; then
			new_array+=("${array[i]}")
		fi
	done; unset i

	array=("${new_array[@]}")
	unset new_array
}

util.fetch() {
	if curl -fsS "$@"; then :; else
		return $?
	fi
}
