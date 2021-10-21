# shellcheck shell=bash

ui.private.select_loop() {
	nodejs.private.select_version "$version_index" "${versions[@]}"
	while :; do
		read -rsN1 key

		case "$key" in
		g)
			version_index=0
			;;
		# C-b
		$'\x02')
			;;
		# C-u
		$'\x15')
			;;
		# k, C-p, up
		k|$'\x10')
			if ((version_index > 0)); then
				version_index=$((version_index-1))
			fi
			;;
		# j, C-n
		j|$'\x0e')
			if ((version_index < ${#versions[@]}-1)); then
				version_index=$((version_index+1))
			fi
			;;
		# C-d
		$'\x04')
			# TODO: exit better
			exit
			;;
		# C-f
		$'\x06')
			;;
		G)
			version_index=$((${#versions[@]}-1))
			;;
		q|'')
			# TODO: exit better
			exit
			;;
		# escape
		$'\x1b')
			if ! read -rsN2 -t 0.1 key; then
				# just escape; no sequence
				# TODO: exit better
				exit
			fi

			case "$key" in
			# up
			$'\x5b\x41')
				if ((version_index > 0)); then
					version_index=$((version_index-1))
				fi
				;;
			# down
			$'\x5b\x42')
				if ((version_index < ${#versions[@]}-1)); then
					version_index=$((version_index+1))
				fi
				;;
			*)
				continue
				;;
			esac
			;;
		*)
			continue
		esac
		unset key

		nodejs.private.select_version "$version_index" "${versions[@]}"
	done
	unset key
}

ui.select_version() {
	local current_version_index="$1"
	local json="$2"

	local -a versions=()
	readarray -t versions < <(jq -r '.[] | .version' <<< "$json" | sort -V)

	ui.private.select_loop "$current_version_index" "${versions[@]}"
}
