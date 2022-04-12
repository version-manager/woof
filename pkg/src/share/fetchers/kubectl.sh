# shellcheck shell=bash
source "${0%/*}/util/util.sh"

parse_kubectl() {
	local regex="refs/tags/kubernetes-(.*)"
	local _hash= tag_name=
	while read -r _hash tag_name; do
		if [[ $tag_name =~ $regex ]]; then
			tag_name=${BASH_REMATCH[1]}
			local url="https://dl.k8s.io/release/v$tag_name/bin/linux/amd64/kubectl"
			printf '%s\n' "kubectl|$tag_name|linux|amd64|$url"
		fi
	done < <(git ls-remote --tags --refs 'https://github.com/kubernetes/kubectl')
}

if is_main; then
	parse_kubectl "$@"
fi
