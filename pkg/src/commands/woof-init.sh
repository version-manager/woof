# shellcheck shell=bash

woof-init() {
	local shell="$1"

	if [ -z "$shell" ]; then
		print.die 'Shell not specified'
	fi

	if [[ $shell != @(fish|zsh|ksh|bash|sh) ]]; then
		print.die 'Shell not supported'
	fi

	var.get_dir 'global' 'bin'
	shell.path_prepend "$REPLY"
	woof_override_cd
}

shell.variable_assignment() {
	local variable="$1"
	local value="$2"

	case $shell in
	fish)
		printf '%s\n' "set $variable \"$value\""
		;;
	*)
		printf '%s\n' "$variable=\"$value\""
		;;
	esac
}

shell.variable_export() {
	local variable="$1"

	case $shell in
	fish)
		printf '%s\n' "set -gx $variable"
		;;
	zsh|ksh|bash|sh)
		printf '%s\n' "export $variable"
		;;
	esac
}

shell.path_prepend() {
	local value="$1"

	case $shell in
	fish)
		printf '%s\n' "if not contains $value \$PATH
   set PATH $value
end"
		;;
	zsh|ksh|bash|sh)
		printf '%s\n' "case :\$PATH: in
   *:\"$value\":*) :;;
   *) PATH=$value\${PATH:+:\$PATH}
esac"
		;;
	esac
}

shell.register_completion() {
	local dir="$1"
	local name="$2"

	case $shell in
	fish)
		printf '%s\n' "source $dir/$name.fish"
		;;
	zsh)
		printf '%s\n' "fpath=(\"$dir\" \$fpath)"
		;;
	ksh)
		;;
	bash)
		printf '%s\n' "source \"$dir/$name.bash\""
		;;
	sh)
		;;
	esac
}

shell.register_completions() {
	local dir="$1"

	case $shell in
	fish)

		;;
	zsh)
		printf '%s\n' "fpath=(\"$dir/zsh/compsys\" \$fpath)
   if [ -d \"$dir/zsh/compctl\" ]; then
      for __f in \"$dir/zsh/compctl/*; do
         source \"\$__f\"
      done; unset -v __f
   fi"
		;;
	ksh)
		;;
	bash)
		printf '%s\n' "if [ -d \"$dir/bash/\" ]; then
   for __f in \"$dir/bash\"/*; do
      if [ -f \"\$__f\" ]; then
         source \"\$__f\"
      fi
   done; unset -v __f
fi"
		;;
	sh)
		;;
	esac
}

shell.source() {
	local dir="$1"
	local file="$2"

	case $shell in
	fish)
		printf '%s\n' "source \"$dir/$file\".fish"
		;;
	zsh|ksh|bash)
		printf '%s\n' "source \"$dir/$file.sh\""
		;;
	sh)
		printf '%s\n' ". \"$dir/$file.sh\""
		;;
	esac
}

woof_override_cd() {
	case $shell in
	fish)
		cat<<-"EOF"
		function cd
		  woof tool cd-override
		  builtin cd "$@"
		end
		EOF
		;;
	zsh|ksh|bash|sh)
		cat<<-"EOF"
		cd() {
		  woof tool cd-override
		  builtin cd "$@"
		}
		EOF
		printf '%s\n' "fpath=(\"$dir\" \$fpath)"
		;;
	esac
}