# shellcheck shell=bash

woof-init() {
	local shell="$1"

	printf '%s' '# shellcheck shell=bash

if [ "${PATH#*$XDG_DATA_HOME/woof/symlinks-global/bin}" = "$PATH" ]; then
  export PATH="$XDG_DATA_HOME/woof/symlinks-global/bin:$PATH"
fi
'
}
