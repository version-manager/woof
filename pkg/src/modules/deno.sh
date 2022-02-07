# shellcheck shell=bash

deno.matrix() {
	local -a versions=()
	m.git_tag_to_versions_array 'versions' 'https://github.com/denoland/deno' 'refs/tags/v'
	versions=("${versions[@]/#/v}")

	local version=
	for version in "${versions[@]}"; do
		# TODO:  This prints too many options
		printf '%s\n' "$version|darwin|amd64|https://dl.deno.land/release/$version/deno-x86_64-apple-darwin.zip"
		printf '%s\n' "$version|linux|amd64|https://dl.deno.land/release/$version/deno-x86_64-unknown-linux-gnu.zip"
		printf '%s\n' "$version|windows|amd64|https://dl.deno.land/release/$version/deno-x86_64-pc-windows-msvc.zip"
	done; unset -v version
}

deno.install() {
	local url="$1"
	local version="$2"

	m.fetch -o file.zip "$url"
	mkdir -p 'dir/bin'
	m.ensure unzip -qq file.zip -d 'dir/bin'
	bash

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
