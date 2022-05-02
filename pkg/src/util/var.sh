# shellcheck shell=bash

var.get_cached_matrix_file() {
	unset -v REPLY
	REPLY="$WOOF_CACHE_HOME/matrices/$1.txt"
}

var.get_module_install_dir() {
	unset -v REPLY
	REPLY="$WOOF_STATE_HOME/installs/$1"
}

var.get_dir() {
	unset -v REPLY
	REPLY="$WOOF_STATE_HOME/$1-$2"
}
