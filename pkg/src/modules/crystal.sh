# shellcheck shell=bash

crystal.matrix() {
	local crystal_url='https://api.github.com/repos/crystal-lang/crystal/releases'

	local text=
	if ! text="$(m.fetch "$crystal_url")"; then
		print.die "Could not fetch '$crystal_url'"
	fi

	python3 "$BASALT_PACKAGE_DIR/pkg/src/share/parse-crystal.py" <<< "$text"
}

crystal.install() {
	local url="$1"
	local version="$2"

	m.fetch -o file.tar.gz "$url"
	mkdir -p 'dir'
	m.ensure tar xaf file.tar.gz -C 'dir' --strip-components=1

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
	REPLY_MANS=('./share/man/man1' './share/man/man5')
	REPLY_BASH_COMPLETIONS=('./share/bash-completion/completions')
	REPLY_ZSH_COMPLETIONS=('./share/zsh/site-functions')
}
