# shellcheck shell=bash

# backwards
ui.private.backwards_all() {
	version_index=0
}

ui.private.backwards_full_screen() {
	if ((version_index - global_tty_height > 0)); then
		version_index=$((version_index - global_tty_height))
	else
		version_index=0
	fi
}

ui.private.backwards_half_screen() {
	if ((version_index - (global_tty_height/2) > 0)); then
		version_index=$((version_index - (global_tty_height/2)))
	else
		version_index=0
	fi
}

ui.private.backwards_one() {
	if ((version_index > 0)); then
		version_index=$((version_index-1))
	fi
}

# forwards
ui.private.forwards_full_screen() {
	if ((version_index + global_tty_height < ${#versions[@]})); then
				version_index=$((version_index + global_tty_height))
			else
				version_index=$((${#versions[@]}-1))
			fi
}

ui.private.fowards_half_screen() {
	if ((version_index + (global_tty_height/2) < ${#versions[@]})); then
		version_index=$((version_index + (global_tty_height/2)))
	else
		version_index=$((${#versions[@]}-1))
	fi
}

ui.private.forwards_one() {
	if ((version_index+1 < ${#versions[@]})); then
		version_index=$((version_index+1))
	fi
}

ui.private.forwards_all() {
	version_index=$((${#versions[@]}-1))
}

ui.private.select_loop() {
	unset REPLY; REPLY=

	local original_version_index="$1"
	nodejs.private.select_version "$version_index" "${versions[@]}"
	while :; do
		read -rsN1 key

		case "$key" in
		g) ui.private.backwards_all ;;
		$'\x02') ui.private.backwards_full_screen ;; # C-b
		$'\x15') ui.private.backwards_half_screen ;; # C-u
		k|$'\x10') ui.private.backwards_one ;; # k, C-p
		$'\x06') ui.private.forwards_full_screen ;; # C-f
		$'\x04') ui.private.fowards_half_screen ;; # C-d
		j|$'\x0e') ui.private.forwards_one ;; # j, C-n
		G) ui.private.forwards_all ;;
		''|$'\x0d') break ;; # enter (success)
		q|$'\x7f') # q, backspace (fail)
			version_index="$original_version_index"
			break
			;;
		$'\x1b') # escape
			if ! read -rsN1 -t 0.1 key; then
				# escape (fail)
				version_index="$original_version_index"
				break
			fi

			case "$key" in
			$'\x5b')
				if ! read -rsN1 -t 0.1 key; then
					# escape (fail)
					version_index="$original_version_index"
					break
				fi

				case "$key" in
				$'\x41') ui.private.backwards_one ;; # up
				$'\x42') ui.private.forwards_one ;; # down
				$'\x43') ui.private.forwards_one ;; # right
				$'\x44') ui.private.backwards_one ;; # left
				$'\x48') ui.private.backwards_all ;; # home
				$'\x46') ui.private.forwards_all ;; # end
				$'\x35')
					if ! read -rsN1 -t 0.1 key; then
						# escape (fail)
						version_index="$original_version_index"
						break
					fi

					case "$key" in
					$'\x7e') ui.private.backwards_full_screen ;; # pageup
					esac
					;;
				$'\x36')
					if ! read -rsN1 -t 0.1 key; then
						# escape (fail)
						version_index="$original_version_index"
						break
					fi

					case "$key" in
					$'\x7e') ui.private.forwards_full_screen ;; # pagedown
					esac
				esac
				;;
			esac
			;;
		esac

		echo "$version_index" "${#versions[@]}" >&2
		nodejs.private.select_version "$version_index" "${versions[@]}"
	done
	unset key

	REPLY="$version_index"
}

ui.select_version() {
	local current_version_index="$1"
	local json="$2"

	local -a versions=()
	readarray -t versions < <(jq -r '.[] | .version' <<< "$json" | sort -V)

	ui.private.select_loop "$current_version_index" "${versions[@]}"
}
