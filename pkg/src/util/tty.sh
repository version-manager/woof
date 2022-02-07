# shellcheck shell=bash

# TODO: tput optional
tty.fullscreen_init() {
	global_stty_saved="$(stty --save)"
	stty -echo
	tput civis 2>/dev/null # cursor to invisible
	tput sc # save cursor position
	tput smcup 2>/dev/null # save screen contents

	clear
	read -r global_tty_height global_tty_width < <(stty size)
}

tty.fullscreen_deinit() {
	tput rmcup 2>/dev/null # restore screen contents
	tput rc # restore cursor position
	tput cnorm 2>/dev/null # cursor to normal
	if [ -z "$global_stty_saved" ]; then
		stty sane
		print.warn "Variable 'global_stty_saved' is empty. Falling back to 'stty sane'"
	else
		stty "$global_stty_saved"
	fi
}

# backwards
tty.private.backwards_all() {
	new_version_index=0
}

tty.private.backwards_full_screen() {
	if ((new_version_index - global_tty_height > 0)); then
		new_version_index=$((new_version_index - global_tty_height))
	else
		new_version_index=0
	fi
}

tty.private.backwards_half_screen() {
	if ((new_version_index - (global_tty_height/2) > 0)); then
		new_version_index=$((new_version_index - (global_tty_height/2)))
	else
		new_version_index=0
	fi
}

tty.private.backwards_one() {
	if ((new_version_index > 0)); then
		new_version_index=$((new_version_index-1))
	fi
}

# forwards
tty.private.forwards_full_screen() {
	local array_length=$1

	if ((new_version_index + global_tty_height < array_length)); then
		new_version_index=$((new_version_index + global_tty_height))
	else
		new_version_index=$((array_length-1))
	fi
}

tty.private.forwards_half_screen() {
	local array_length=$1

	if ((new_version_index + (global_tty_height/2) < array_length)); then
		new_version_index=$((new_version_index + (global_tty_height/2)))
	else
		new_version_index=$((array_length-1))
	fi
}

tty.private.forwards_one() {
	local array_length=$1

	if ((new_version_index+1 < array_length)); then
		new_version_index=$((new_version_index+1))
	fi
}

tty.private.forwards_all() {
	local array_length=$1

	new_version_index=$((array_length-1))
}

tty.private.print_list() {
	local index="$1"; shift

	# index represents the center (ex. 17)

	local start=$((index - (global_tty_height / 2)))
	local end=$((start + global_tty_height))

	# cursor to home
	printf '\033[%d;%dH' 0 0 # tput cup 0 0

	local i= str= prefix=
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
		# shellcheck disable=SC2059
		printf "$str"
	done; unset i
}

tty.multiselect() {
	unset REPLY; REPLY=
	local old_version="$1"; shift
	local select_keys_variable_name="$1"; shift
	local select_table_variable_name="$1"; shift

	local -n select_keys_variable="$select_keys_variable_name"
	local -n select_table_variable="$select_table_variable_name"

	if (( ${#select_keys_variable[@]} == 0)); then
		print.die "Internal: Array should be greater than 0"
	fi

	if [ -z "$old_version" ]; then
		old_version="${select_keys_variable[0]}"
	fi

	# If '$old_version' is not in 'select_table_version', then
	if ! [ "${select_table_variable[$old_version]+x}" ]; then
		old_version="${select_keys_variable[0]}"
	fi

	if ! util.key_to_index "$select_keys_variable_name" "$old_version"; then
		tty.fullscreen_deinit
		print.fatal "Key not '$old_version' not found in array '$select_keys_variable_name'"
	fi
	old_version_index="$REPLY"
	new_version_index="$old_version_index"

	# TODO: properly deinit on errors etc.
	tty.fullscreen_init
	tty.private.print_list "$new_version_index" "${select_keys_variable[@]}"
	while :; do
		if ! read -rsN1 key; then
			print.die 'Could not read input'
		fi

		case "$key" in
		g) tty.private.backwards_all ;;
		$'\x02') tty.private.backwards_full_screen ;; # C-b
		$'\x15') tty.private.backwards_half_screen ;; # C-u
		k|$'\x10') tty.private.backwards_one ;; # k, C-p
		$'\x06') tty.private.forwards_full_screen ${#select_keys_variable[@]} ;; # C-f
		$'\x04') tty.private.forwards_half_screen ${#select_keys_variable[@]} ;; # C-d
		j|$'\x0e') tty.private.forwards_one ${#select_keys_variable[@]} ;; # j, C-n
		G) tty.private.forwards_all ${#select_keys_variable[@]} ;;
		$'\n'|$'\x0d') break ;; # enter (success)
		q|$'\x7f') # q, backspace (fail)
			new_version_index="$old_version_index"
			break
			;;
		$'\x1b') # escape
			if ! read -rsN1 -t 0.1 key; then
				# escape (fail)
				new_version_index="$old_version_index"
				break
			fi

			case "$key" in
			$'\x5b')
				if ! read -rsN1 -t 0.1 key; then
					# escape (fail)
					new_version_index="$old_version_index"
					break
				fi

				case "$key" in
				$'\x41') tty.private.backwards_one ;; # up
				$'\x42') tty.private.forwards_one ${#select_keys_variable[@]} ;; # down
				$'\x43') tty.private.forwards_one ${#select_keys_variable[@]} ;; # right
				$'\x44') tty.private.backwards_one ;; # left
				$'\x48') tty.private.backwards_all ;; # home
				$'\x46') tty.private.forwards_all ${#select_keys_variable[@]} ;; # end
				$'\x35')
					if ! read -rsN1 -t 0.1 key; then
						# escape (fail)
						new_version_index="$old_version_index"
						break
					fi

					case "$key" in
					$'\x7e') tty.private.backwards_full_screen ;; # pageup
					esac
					;;
				$'\x36')
					if ! read -rsN1 -t 0.1 key; then
						# escape (fail)
						new_version_index="$old_version_index"
						break
					fi

					case "$key" in
					$'\x7e') tty.private.forwards_full_screen ${#select_keys_variable[@]} ;; # pagedown
					esac
				esac
				;;
			esac
			;;
		esac

		tty.private.print_list "$new_version_index" "${select_keys_variable[@]}"
	done
	unset key
	tty.fullscreen_deinit

	REPLY="${select_keys_variable[$new_version_index]}"
}
