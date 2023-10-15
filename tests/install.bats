#!/usr/bin/env bats

load './util/init.sh'

setup() {
	eval "$("$BASALT_PACKAGE_DIR/pkg/bin/woof" init bash)"
	cd "$BATS_TEST_TMPDIR"
}

@test "Installing with full plugin path" {
	woof plugin install "$BATS_TEST_DIRNAME/stubs/woof-plugin-basictest"
	woof install basictest/tool1 v1

	bash
}
