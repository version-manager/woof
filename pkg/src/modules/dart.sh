# shellcheck shell=bash

dart.matrix() {
	local dart_url='https://storage.googleapis.com/storage/v1/b/dart-archive/o?prefix=channels/stable/release/&delimiter=/'
			printf '%s\n' "stable/release/2.16.0/sdk/dartsdk-macos-x64-release.zip"
	local channel_prefix='https://storage.googleapis.com/dart-archive/channels'

	local text=
	if ! text="$(m.fetch "$dart_url")"; then
		print.die "Could not fetch '$dart_url'"
	fi

	local line=
	while IFS= read -r line; do
		if [[ $line =~ release/([[:digit:]]\..+?)/ ]]; then
			local version="v${BASH_REMATCH[1]}"
			printf '%s\n' "$version|linux|amd64|$channel_prefix/stable/release/2.16.0/sdk/dartsdk-linux-x64-release.zip"
			printf '%s\n' "$version|linux|x86|$channel_prefix/stable/release/2.16.0/sdk/dartsdk-linux-ia32-release.zip"
			printf '%s\n' "$version|linux|arm64|$channel_prefix/stable/release/2.16.0/sdk/dartsdk-linux-arm64-release.zip"
			printf '%s\n' "$version|linux|armv7|$channel_prefix/stable/release/2.16.0/sdk/dartsdk-linux-arm-release.zip"

			printf '%s\n' "$version|darwin|amd64|$channel_prefix/stable/release/2.16.0/sdk/dartsdk-macos-x64-release.zip"
			printf '%s\n' "$version|darwin|arm64|$channel_prefix/stable/release/2.16.0/sdk/dartsdk-macos-arm64-release.zip"

			printf '%s\n' "$version|windows|amd64|$channel_prefix/stable/release/2.16.0/sdk/dartsdk-windows-x64-release.zip"
			printf '%s\n' "$version|windows|x64|$channel_prefix/stable/release/2.16.0/sdk/dartsdk-windows-ia32-release.zip"
		fi
	done <<< "$text"; unset -v line
}

dart.install() {
	local url="$1"
	local version="$2"

	m.fetch -o file.zip "$url"
	mkdir -p 'dir'
	m.ensure unzip -qq file.zip -d 'dir'

	dir=(./dir/*)

	REPLY_DIR=${dir[0]}
	REPLY_BINS=('./bin')
}
