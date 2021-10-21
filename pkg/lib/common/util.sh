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

	trap g.stty_deinit EXIT SIGHUP SIGABRT SIGINT SIGQUIT SIGTERM SIGTSTP
	g.stty_deinit() {
		tput rmcup 2>/dev/null # restore screen contents
		tput rc # restore cursor position
		tput cnorm 2>/dev/null # cursor to normal
		stty "$global_stty_saved"

		exit
	}

	trap trap.sigwinch SIGWINCH
	trap.sigwinch() {
		read -r global_tty_height global_tty_width < <(stty size)
	}

	g.stty_init
}


util.fetch() {
	if command curl -fsS "$@"; then :; else
		return $?
	fi
}
