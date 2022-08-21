# shellcheck shell=bash

# shellcheck disable=SC2059
tty.fullscreen_init() {
	stty -echo
	term.cursor_hide -p
	term.cursor_savepos -p
	term.screen_save -p

	term.erase_saved_lines -p
	read -r global_tty_height global_tty_width < <(stty size)
}

# shellcheck disable=SC2059
tty.fullscreen_deinit() {
	term.screen_restore -p
	term.cursor_restorepos -p
	term.cursor_show -p
	stty echo
}

tty.all_save() {
	term.cursor_savepos -p
	term.screen_save -p
}
tty.all_restore() {
	term.screen_restore -p
	term.cursor_restorepos -p
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
	local index="$1"
	if ! shift; then
		util.print_fatal_die 'Failed to shift'
	fi

	# index represents the center (ex. 17)

	local start=$((index - (global_tty_height / 2)))
	local end=$((start + global_tty_height))

	term.cursor_to -p 0 0

	# shellcheck disable=SC1007
	local i= str= prefix=
	for ((i=start; i<end; i++)); do
		if ((i != start)); then
			term.cursor_down -p 1
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

		printf '\r'
		term.erase_line_end -p
		# shellcheck disable=SC2059
		printf "$str"
	done; unset -v i
}

tty.multiselect() {
	unset REPLY; REPLY=
	local old_version="$1"; if ! shift; then util.print_fatal_die 'Failed to shift'; fi
	local select_keys_variable_name="$1"; if ! shift; then util.print_fatal_die 'Failed to shift'; fi
	local select_table_variable_name="$1"; if ! shift; then util.print_fatal_die 'Failed to shift'; fi

	local -n select_keys_variable="$select_keys_variable_name"
	local -n select_table_variable="$select_table_variable_name"

	if (( ${#select_keys_variable[@]} == 0)); then
		util.print_fatal_die "Array should be greater than 0"
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
		util.print_error_die "Key not '$old_version' not found in array '$select_keys_variable_name'"
	fi
	old_version_index="$REPLY"
	new_version_index="$old_version_index"

	# TODO: # trap 'tty.fullscreen_deinit; exit' EXIT SIGHUP SIGABRT SIGINT SIGQUIT SIGTERM SIGTSTP
	trap.sigint_tty() {
		tty.fullscreen_deinit
	}
	core.trap_add 'trap.sigint_tty' 'EXIT'
	trap.sigcont_tty() {
		tty.fullscreen_init
	}
	core.trap_add 'trap.sigcont_tty' 'SIGCONT'

	tty.fullscreen_init

	tty.private.print_list "$new_version_index" "${select_keys_variable[@]}"
	while :; do
		if ! read -rsN1 key; then
			util.print_error_die 'Could not read input'
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
	unset -v key
	tty.fullscreen_deinit

	core.trap_remove 'trap.sigint_tty' 'EXIT'
	core.trap_remove 'trap.sigcont_tty' 'SIGCONT'

	REPLY="${select_keys_variable[$new_version_index]}"
}
