# shellcheck shell=bash
source "${0%/*}/util/util.sh"

parse_nim() {
	local nim_url='https://nim-lang.org/install.html'

	local text=
	if ! text=$(curl -fsSL "$nim_url"); then
		f.die "Could not fetch '$nim_url'"
	fi

	local os='windows'
	local version=''

	local line=
	local -i read_i=-1
	while IFS= read -r line; do
		if ((read_i == 1)); then
			((read_i--))
			if [[ $line =~ \<a\ href=\"(.+?)\" ]]; then
				printf '%s\n' "Nim|v$version|$os|x86_64|https://nim-lang.org${BASH_REMATCH[1]}"
			fi
			continue
		elif ((read_i == 0)); then
			((read_i--))
			if [[ $line =~ \<a\ href=\"(.+?)\" ]]; then
				printf '%s\n' "Nim|v$version|$os|x86|https://nim-lang.org${BASH_REMATCH[1]}"
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
	done <<< "$text"
}

if f.is_main; then
	parse_nim "$@"
fi
