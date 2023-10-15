# shellcheck shell=bash

tool1.table() {
	T1|v1|linux|x86_64|https://example.com/downloads/tool1-v1-linux-x86_64.tar.gz
	T1|v2|linux|x86_64|https://example.com/downloads/tool1-v2-linux-x86_64.tar.gz
}

tool1.install() {
	local url="$1"
	local version="$2"

	mkdir -p './dir/bin'
	if [ "$version" = 'v1' ]; then
		printf '%s\n' 'echo "hello v1"' >> './dir/bin/tool1'
	elif [ "$version" = 'v2' ]; then
		printf '%s\n' '"echo hello v2"' >> './dir/bin/tool1'
	fi
	chmod +x './dir/bin/tool1'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
