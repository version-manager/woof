# shellcheck shell=bash

nodejs.matrix() {
	local json=
	if ! json="$(m.fetch https://nodejs.org/download/release/index.json)"; then
		core.err_set "Could not fetch 'https://nodejs.org/download/release/index.json'"
		return
	fi

	# Assumes every line contains a single Json object
	local line=
	while IFS= read -r line; do
		if [ "${line::1}" != '{' ]; then
			continue
		fi

		local regex="\"version\"[\t ]*:[\t ]*\"(v[0-9|.]+)\"[ \t]*,[\t ]*\"date\"[\t ]*:[\t ]*\"([0-9-]+)\"[\t ]*,[ \t]*\"files\"[ \t]*:[ \t]*\[(.*?)\]"
		if [[ $line =~ $regex ]]; then
			local version_string="${BASH_REMATCH[1]}"
			local release_date="${BASH_REMATCH[2]}"
			local platforms_arrstring="${BASH_REMATCH[3]}"

			if [ -z "$version_string" ] || [ -z "$release_date" ] || [ -z "$platforms_arrstring" ]; then
				continue
			fi

			local -a platforms=()
			readarray -td ',' platforms <<< "$platforms_arrstring"
			platforms=("${platforms[@]#\"}"); platforms=("${platforms[@]%\"*}")

			for platform in "${platforms[@]}"; do
				local normalized_platform=
				case $platform in
					linux-x86) normalized_platform='linux|x86' ;;
					linux-x64) normalized_platform='linux|amd64' ;;
					linux-armv7l) normalized_platform='linux|armv7l' ;;
					linux-arm64) normalized_platform='linux|arm64' ;;
					osx-x32-tar) normalized_platform='darwin|x86' ;;
					osx-x64-tar) normalized_platform='darwin|amd64' ;;
					osx-arm64-tar) normalized_platform='darwin|arm64' ;;
					*) m.log "nodejs: $version_string: $platform: Not supported"; continue ;;
				esac

				local platform_uri="$platform"
				case "$platform" in
					osx-x32-tar) platform_uri='darwin-x86' ;;
					osx-x64-tar) platform_uri='darwin-x64' ;;
					osx-arm64-tar) platform_uri='darwin-arm64' ;;
				esac

				# Ex. v0.8.6|linux|x86|https://nodejs.org/download/release/v0.8.6/node-v0.8.6-linux-x86.tar.gz|(Released 2012-08-06)
				printf '%s\n' "$version_string|$normalized_platform|https://nodejs.org/download/release/$version_string/node-$version_string-$platform_uri.tar.gz|(Released $release_date)"
			done; unset platform
		fi; unset regex
	done <<< "$json"; unset line
}

nodejs.install() {
	local url="$1"
	local version="$2"

	m.ensure curl -fsSo file.tar.gz "$url"
	mkdir -p 'dir'
	m.ensure tar xaf file.tar.gz -C 'dir' --strip-components=1

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
	REPLY_MANS=('./share/man/man1')
}
