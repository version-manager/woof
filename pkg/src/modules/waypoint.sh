# shellcheck shell=bash

waypoint.matrix() {
	bash "$BASALT_PACKAGE_DIR/pkg/src/filters/hashicorp.sh" 'waypoint'
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