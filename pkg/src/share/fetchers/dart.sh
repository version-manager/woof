# shellcheck shell=bash
source "${0%/*}/util/util.sh"

parseDart() {
	local dart_url='https://storage.googleapis.com/storage/v1/b/dart-archive/o?prefix=channels/stable/release/&delimiter=/'
	local channel_prefix='https://storage.googleapis.com/dart-archive/channels'

	local text=
	if ! text=$(curl -fsSL "$dart_url"); then
		print.die "Could not fetch '$dart_url'" # TODO: function no exist
	fi

	local line=
	while IFS= read -r line; do
		if [[ $line =~ release/([[:digit:]]\..+?)/ ]]; then
			local version="v${BASH_REMATCH[1]}"
			printf '%s\n' "Dart|$version|linux|amd64|$channel_prefix/stable/release/$version/sdk/dartsdk-linux-x64-release.zip"
			printf '%s\n' "Dart|$version|linux|x86|$channel_prefix/stable/release/$version/sdk/dartsdk-linux-ia32-release.zip"
			printf '%s\n' "Dart|$version|linux|arm64|$channel_prefix/stable/release/$version/sdk/dartsdk-linux-arm64-release.zip"
			printf '%s\n' "Dart|$version|linux|armv7|$channel_prefix/stable/release/$version/sdk/dartsdk-linux-arm-release.zip"

			printf '%s\n' "Dart|$version|darwin|amd64|$channel_prefix/stable/release/$version/sdk/dartsdk-macos-x64-release.zip"
			printf '%s\n' "Dart|$version|darwin|arm64|$channel_prefix/stable/release/$version/sdk/dartsdk-macos-arm64-release.zip"

			printf '%s\n' "Dart|$version|windows|amd64|$channel_prefix/stable/release/$version/sdk/dartsdk-windows-x64-release.zip"
			printf '%s\n' "Dart|$version|windows|x64|$channel_prefix/stable/release/$version/sdk/dartsdk-windows-ia32-release.zip"
		fi
	done <<< "$text"
}

if isMain; then
	parseDart "$@"
fi
