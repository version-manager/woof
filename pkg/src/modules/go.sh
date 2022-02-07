# shellcheck shell=bash

go.matrix() {
	local go_url='https://go.dev/dl'

	local text=
	if ! text="$(m.fetch "$go_url")"; then
		print.die "Could not fetch '$go_url'"
	fi

	perl "$BASALT_PACKAGE_DIR/pkg/src/share/parse-go.pl" <<< "$text"
}

go.install() {
	local url="$1"
	local version="$2"

	m.fetch -o file.tar.gz "$url"
	mkdir -p 'dir'
	m.ensure tar xaf file.tar.gz -C 'dir' --strip-components=1

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
	REPLY_MANS=()
}
