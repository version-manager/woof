# shellcheck shell=bash

crystal.matrix() {
	m.fetch_github_release 'crystal-lang/crystal' \
		| jq -rf "$BASALT_PACKAGE_DIR/pkg/src/share/fetchers/crystal.jq"
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
