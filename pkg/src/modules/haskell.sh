# shellcheck shell=bash

haskell.matrix() {
	local haskell_url='https://downloads.haskell.org/~ghc'

	local text=
	if ! text="$(m.fetch "$haskell_url")"; then
		print.die "Could not fetch '$haskell_url'"
	fi

	while IFS= read -r line; do
		printf "%s\n" ">> $line"
		if [[ $line =~ a\ href=\"(.*?)\" ]]; then
			local version="${BASH_REMATCH[1]}"
			printf '%s\n' "}"
		fi
	done <<< "$text"
}
