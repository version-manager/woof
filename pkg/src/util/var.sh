# shellcheck shell=bash

var.get_tool_file() {
	var.get_dir 'plugins'
	local plugins_dir="$REPLY"

	unset -v REPLY
	REPLY="$plugins_dir/woof-plugin-$1/tools/$2.sh"
}

var.get_plugin_table_file() {
	unset -v REPLY
	REPLY="$WOOF_CACHE_HOME/tables/$1.txt"
}

var.get_plugin_workspace_dir() {
	unset -v REPLY
	REPLY="$WOOF_STATE_HOME/workspace-$1"
}

var.get_dir() {
	unset -v REPLY
	REPLY="$WOOF_STATE_HOME/$1${2:+/$2}"
}
