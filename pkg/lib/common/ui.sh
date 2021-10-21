# shellcheck shell=bash

# printing
ui.private.print_list() {
	local index="$1"; shift
	# index represents the center (ex. 17)

	local start=$((index - (global_tty_height / 2)))
	local end=$((start + global_tty_height))

	# cursor to home
	printf '\033[%d;%dH' 0 0 # tput cup 0 0

	local str= prefix=
	for ((i=start; i<end; i++)); do
		if ((i != start)); then
			# cursor down one line
			printf '\e[1B' # tput cud1
		fi

		if ((index+1 == i)); then
			prefix='> '
		else
			prefix='  '
		fi

		# Greater than zero since "$0"
		if ((i > 0 && i<$#+1)); then
			str="${prefix}${*:$i:1}"
		else
			str="${prefix}\033[1;30m~\033[0m"
		fi

		printf '\r\e[0K' # printf '\r'; tput el
		printf "$str"
	done; unset i

	printf '%s\n' "$index" >&2
}

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
	local array_length=$1

	if ((version_index + global_tty_height < array_length)); then
		version_index=$((version_index + global_tty_height))
	else
		version_index=$((array_length-1))
	fi
}

ui.private.forwards_half_screen() {
	local array_length=$1

	if ((version_index + (global_tty_height/2) < array_length)); then
		version_index=$((version_index + (global_tty_height/2)))
	else
		version_index=$((array_length-1))
	fi
}

ui.private.forwards_one() {
	local array_length=$1

	if ((version_index+1 < array_length)); then
		version_index=$((version_index+1))
	fi
}

ui.private.forwards_all() {
	local array_length=$1

	version_index=$((array_length-1))
}

ui.select_version() {
	unset REPLY; REPLY=

	local original_version_index="$1"; shift

	local version_index="$original_version_index"

	ui.private.print_list "$version_index" "$@"
	while :; do
		if ! read -rsN1 key; then
			die 'Could not read input'
		fi

		case "$key" in
		g) ui.private.backwards_all ;;
		$'\x02') ui.private.backwards_full_screen ;; # C-b
		$'\x15') ui.private.backwards_half_screen ;; # C-u
		k|$'\x10') ui.private.backwards_one ;; # k, C-p
		$'\x06') ui.private.forwards_full_screen $# ;; # C-f
		$'\x04') ui.private.forwards_half_screen $# ;; # C-d
		j|$'\x0e') ui.private.forwards_one $# ;; # j, C-n
		G) ui.private.forwards_all $# ;;
		$'\n'|$'\x0d') break ;; # enter (success)
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
				$'\x42') ui.private.forwards_one $# ;; # down
				$'\x43') ui.private.forwards_one $# ;; # right
				$'\x44') ui.private.backwards_one ;; # left
				$'\x48') ui.private.backwards_all ;; # home
				$'\x46') ui.private.forwards_all $# ;; # end
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
					$'\x7e') ui.private.forwards_full_screen $# ;; # pagedown
					esac
				esac
				;;
			esac
			;;
		esac

		ui.private.print_list "$version_index" "$@"
	done
	unset key

	REPLY="$version_index"
}
