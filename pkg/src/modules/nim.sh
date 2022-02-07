# shellcheck shell=bash

nim.matrix() {
	local nim_url='https://nim-lang.org/install.html'

	local text=
	if ! text="$(m.fetch "$nim_url")"; then
		print.die "Could not fetch '$nim_url'"
	fi

	local os='windows'
	local version=''

	local line=
	local -i read_i=-1
	while IFS= read -r line; do
		if ((read_i == 1)); then
			((read_i--))
			if [[ $line =~ \<a\ href=\"(.+?)\" ]]; then
				printf '%s\n' "v$version|$os|amd64|https://nim-lang.org/${BASH_REMATCH[1]}|"
			fi
			continue
		elif ((read_i == 0)); then
			((read_i--))
			if [[ $line =~ \<a\ href=\"(.+?)\" ]]; then
				printf '%s\n' "v$version|$os|x86|https://nim-lang.org/${BASH_REMATCH[1]}|"
			fi
			continue
		fi

		if [[ $line =~ \<h2\>Unix\</h2\> ]]; then
			os='linux'
		elif [[ $line =~ \<h2\>Windows\</h2\> ]]; then
			os='windows'
		fi

		if [[ $line =~ \<li\>Nim\ (.+?): ]]; then
			read_i=1
			version=${BASH_REMATCH[1]}
		fi
	done <<< "$text"; unset -v line
}

nim.install() {
	local url="$1"
	local version="$2"

	m.fetch -o file.tar.xz "$url"
	mkdir -p 'dir'
	m.ensure tar xaf file.tar.xz -C 'dir' --strip-components=1

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}