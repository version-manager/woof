# shellcheck shell=bash

var.get_module_table_file() {
	unset -v REPLY
	REPLY="$WOOF_CACHE_HOME/matrices/$1.txt"
}

var.get_module_workspace_dir() {
	unset -v REPLY
	REPLY="$WOOF_STATE_HOME/workspace-$1"
}

var.get_module_install_dir() {
	unset -v REPLY
	REPLY="$WOOF_STATE_HOME/installs/$1"
}

var.get_dir() {
	unset -v REPLY
	REPLY="$WOOF_STATE_HOME/$1/$2"
}
