# shellcheck shell=bash
source "${0%/*}/util/util.sh"

parse_dart() {
	if [ -t 0 ]; then
		printf '%s' 'Processed:' >/dev/tty
	fi

	local prefix="https://storage.googleapis.com/dart-archive/channels"
	local regex="^refs/tags/[[:digit:]]+\\.[[:digit:]]+\\.[[:digit:]]+$"
	local _hash= tag_name=
	while read -ru3 _hash tag_name; do
		if [[ $tag_name =~ $regex ]]; then
			tag_name=${tag_name#refs/tags/}

			# shellcheck disable=SC1007
			local os= arch= normalized_arch=
			while read -r os arch normalized_arch; do
				local url="$prefix/stable/release/$tag_name/sdk/dartsdk-linux-$arch-release.zip"

				# It wasn't super obvious how to get all the binaries associate with
				# a particular version in one go - so we manually check to see if
				# a particular combination exists 
				if curl -sqfL -o /dev/null --head "$url"; then
					printf '%s\n' "Dart|$tag_name|$os|$normalized_arch|$url"
				fi
			done <<< 'linux x64 amd64
linux ia32 x86
linux arm64 arm64
macos x64 amd64
macos arm64 arm64'
			if [ -t 0 ]; then
				printf ' %s' "$tag_name" >/dev/tty
			fi
		fi
	done 3< <(git ls-remote --tags --refs 'https://github.com/dart-lang/sdk')
	if [ -t 0 ]; then
		printf '\n' >/dev/tty
	fi
}

if is_main; then
	parse_dart "$@"
fi
