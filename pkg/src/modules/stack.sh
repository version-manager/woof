# shellcheck shell=bash

stack.matrix() {
	local crystal_url='https://api.github.com/repos/commercialhaskell/stack/releases'

	local text=
	if ! text="$(m.fetch "$crystal_url")"; then
		print.die "Could not fetch '$crystal_url'"
	fi

	python3 "$BASALT_PACKAGE_DIR/pkg/src/share/parse-stack.py" <<< "$text"
}

stack.install() {
	local url="$1"
	local version="$2"

	m.fetch -o file.tar.gz "$url"
	mkdir -p 'dir'
	m.ensure tar xaf file.tar.gz -C 'dir' --strip-components=1
	cd 'dir'
	mkdir 'bin'
	mv './stack' './bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
