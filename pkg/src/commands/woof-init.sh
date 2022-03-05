# shellcheck shell=bash

shell.path_prepend() {
	local value="$1"

	case $shell in
	fish)
		printf '%s\n' "if not contains $value \$PATH
   set PATH $value \$PATH
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

woof-init() {
	local shell="$1"

	shell.path_prepend "${XDG_DATA_HOME:-$HOME/.local/share}/woof/symlinks-global/bin"
	printf '\n'
}
