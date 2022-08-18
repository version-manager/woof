# shellcheck shell=bash

var.get_plugin_table_file() {
	unset -v REPLY
	REPLY="$WOOF_CACHE_HOME/tables/$1.txt"
}

var.get_plugin_workspace_dir() {
	unset -v REPLY
	REPLY="$WOOF_STATE_HOME/workspace-$1"
}

var.get_tty_dir() {
	unset -v REPLY; REPLY=

	local tty_output=
	if tty_output=$(tty); then
		tty_output="${tty_output//\//_}"
		var.get_dir 'data-tty' "ttys/${tty_output#_dev_}"
		# shellcheck disable=SC2269
		REPLY="$REPLY"
	else
		return 1
	fi
}

var.get_dir() {
	unset -v REPLY
	REPLY="$WOOF_STATE_HOME/$1${2:+/$2}"
}
