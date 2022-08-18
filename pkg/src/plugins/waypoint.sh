# shellcheck shell=bash

waypoint.table() {
	m.run_bash 'hashicorp' 'waypoint'
}

waypoint.install() {
	local url="$1"
	local version="$2"

	m.fetch -o './waypoint.zip' "$url"
	mkdir -p './dir/bin'
	m.ensure unzip -qq './waypoint.zip' -d './dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}