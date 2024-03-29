# shellcheck shell=bash

test_index_object_keys() {
	unset -v REPLY; REPLY=
	local object_name="$1"
	local n="$2"

	local -n __object="$object_name"

	local key= i=0
	for key in "${!__object[@]}"; do
		if ((i == n)); then
			REPLY="$key"
		fi

		i=$((i+1))
	done
}

test_snapshot_cmd() {
	local filename="$1"
	if ! shift; then
		core.fatal 'Failed to shift'
	fi

	local snapshot_file="$BATS_TEST_DIRNAME/snapshots/$filename"

	util.mkdirp "${snapshot_file%/*}"

	"$@" > "$snapshot_file"
}
