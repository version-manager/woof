# shellcheck shell=bash

waypoint.table() {
	p.run_bash 'hashicorp' 'waypoint'
}

waypoint.install() {
	local url="$1"
	local version="$2"

	p.fetch -o './waypoint.zip' "$url"
	p.mkdir './dir/bin'
	p.unpack './waypoint.zip' -d'./dir/bin'

	REPLY_DIR='./dir'
	REPLY_BINS=('./bin')
}
