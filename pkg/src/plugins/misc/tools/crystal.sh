# shellcheck shell=bash

crystal.table() {
	p.fetch_github_release 'crystal-lang/crystal' \
		| p.run_jq 'github-release' \
			--arg global_variant "Crystal" \
			--arg global_regex "^crystal[_-](.+?)-1[_-](?:(?<os>.+?)-)?(?<arch>.+?)\\."
}

crystal.install() {
	local url="$1"
	local version="$2"

	p.fetch -o file.tar.gz "$url"
	p.mkdir './dir'
	p.unpack './file.tar.gz' -d'dir' -s

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
	REPLY_MANS=('./share/man/man1' './share/man/man5')
	REPLY_BASH_COMPLETIONS=('./share/bash-completion/completions')
	REPLY_ZSH_COMPLETIONS=('./share/zsh/site-functions')
}
