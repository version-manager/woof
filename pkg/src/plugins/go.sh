# shellcheck shell=bash

go.table() {
	m.fetch 'https://go.dev/dl' \
		| perl "$BASALT_PACKAGE_DIR/pkg/src/filters/go.pl"
}

go.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './file.tar.gz' "$url"
	mkdir -p './dir'
	m.ensure tar xf './file.tar.gz' -C './dir' --strip-components=1

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}

# TODO: if this (or any others fail), then symlink will fail. Edit so it does not stay as 'installed'
go.switch() {
	# local install_dir="$1"
	# local plugin_version="$2"

	# go install -v 'golang.org/x/tools/gopls@latest'
	# go install -v 'golang.org/x/tools/cmd/goimports@latest'
	# go install -v 'github.com/ramya-rao-a/go-outline@latest'
	# go install -v 'github.com/stamblerre/gocode@latest'
	:
}

go.env() {
	var.get_dir 'data-global' 'common'
	local global_common_dir="$REPLY"

	# FIXME make into m.<>
	# shell.variable_assignment 'GOROOT' "$global_common_dir/goroot"
	# shell.variable_export 'GOROOT'
}
