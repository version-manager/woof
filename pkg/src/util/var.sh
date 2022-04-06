# shellcheck shell=bash

var.get_cached_matrix_file() {
	unset -v REPLY
	REPLY="$WOOF_STATE_HOME/cached/$1-matrix.txt"
}

var.get_module_install_dir() {
	unset -v REPLY
	REPLY="$WOOF_STATE_HOME/installs/$1"
}

var.get_symlink_dir() {
	unset -v REPLY
	REPLY="$WOOF_STATE_HOME/$1-$2"
}

var.get_global_path_dir() {
	unset -v REPLY
	REPLY="$WOOF_STATE_HOME/global-bin"
}

var.get_global_choice_dir() {
	unset -v REPLY
	REPLY="$WOOF_STATE_HOME/global-choice/$1"
}