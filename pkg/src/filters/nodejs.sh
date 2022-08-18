# shellcheck shell=bash
source "${0%/*}/util/util.sh"

parse_nodejs() {
	local nodejs_url='https://nodejs.org/download/release/index.json'

	local json=
	if ! json=$(curl -fsSL "$nodejs_url"); then
		f.die "Could not fetch '$nodejs_url'"
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
			local module_version="${BASH_REMATCH[1]}"
			local release_date="${BASH_REMATCH[2]}"
			local platforms_arrstring="${BASH_REMATCH[3]}"

			if [ -z "$module_version" ] || [ -z "$release_date" ] || [ -z "$platforms_arrstring" ]; then
				continue
			fi

			local -a platforms=()
			readarray -td ',' platforms <<< "$platforms_arrstring"
			platforms=("${platforms[@]#\"}"); platforms=("${platforms[@]%\"*}")

			for platform in "${platforms[@]}"; do
				local normalized_platform=
				case $platform in
					linux-x86) normalized_platform='linux|x86' ;;
					linux-x64) normalized_platform='linux|x86_64' ;;
					linux-armv7l) normalized_platform='linux|armv7l' ;;
					linux-arm64) normalized_platform='linux|arm64' ;;
					osx-x32-tar) normalized_platform='darwin|x86' ;;
					osx-x64-tar) normalized_platform='darwin|x86_64' ;;
					osx-arm64-tar) normalized_platform='darwin|arm64' ;;
				esac

				if [ -z "$normalized_platform" ]; then
					continue
				fi

				printf '%s\n' "NodeJS|$module_version|$normalized_platform|https://nodejs.org/download/release/$module_version/node-$module_version-$platform.tar.gz|$release_date"
			done
		fi
	done <<< "$json"
}

if f.is_main; then
	parse_nodejs "$@"
fi
