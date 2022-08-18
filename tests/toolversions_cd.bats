#!/usr/bin/env bats

load './util/init.sh'

setup() {
	eval "$("$BASALT_PACKAGE_DIR/pkg/bin/woof" init bash)"
	cd "$BATS_TEST_TMPDIR"
}

@test "Warns if using ref protocol" {
	cat > '.tool-versions' <<-"EOF"
	ruby ref:v0.1
	EOF

	run cd .
	assert [ "$status" -eq 0 ]
	assert_line -p "as 'ref:' is not yet supported"
}

@test "Warns if using path protocol" {
	cat > '.tool-versions' <<-"EOF"
	ruby path:../other
	EOF

	run cd .
	assert [ "$status" -eq 0 ]
	assert_line -p "as 'path:' is not yet supported"
}

@test "Warns if using system" {
	cat > '.tool-versions' <<-"EOF"
	ruby system
	EOF

	run cd .
	assert [ "$status" -eq 0 ]
	assert_line -p "as 'system' is not yet supported"
}
